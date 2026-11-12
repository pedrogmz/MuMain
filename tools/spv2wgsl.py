"""SPIR-V blob -> WGSL for the XDL_wgpu (SDL GPU on WebGPU) backend.

Usage: python spv2wgsl.py <in.spv> <out.wgsl>

1. Remaps the descriptor bindings to XDL_wgpu's dense layout: in the sampler
   sets (0 = vertex, 2 = fragment) texture slot i -> binding 2i, its sampler
   -> 2i+1, then storage textures, then storage buffers. Uniform sets (1, 3)
   keep their bindings.
2. Runs naga with --keep-coordinate-space (no Y flip).
3. Post-edits for WebGPU compatibility mode: clip_distances become a plain
   varying at the first free location, flat varyings use (flat, either).
"""
import re
import struct
import subprocess
import sys
import tempfile
import os

OP_TYPE_IMAGE, OP_TYPE_SAMPLER, OP_TYPE_SAMPLED_IMAGE = 25, 26, 27
OP_TYPE_ARRAY, OP_TYPE_RUNTIME_ARRAY, OP_TYPE_STRUCT, OP_TYPE_POINTER = 28, 29, 30, 32
OP_VARIABLE, OP_DECORATE = 59, 71
DEC_BINDING, DEC_SET, DEC_BLOCK, DEC_BUFFER_BLOCK = 33, 34, 2, 3
SC_UNIFORM, SC_STORAGE_BUFFER, SC_UNIFORM_CONSTANT = 2, 12, 0


def remap_bindings(words):
    types = {}  # id -> (opcode, operands)
    pointers = {}  # ptr id -> (storage class, pointee)
    variables = {}  # var id -> (ptr type, storage class)
    decorations = {}  # id -> {decoration: (word index of literal)}
    struct_decos = {}  # id -> set(decorations)
    i = 5
    while i < len(words):
        count, op = words[i] >> 16, words[i] & 0xFFFF
        ops = words[i + 1:i + count]
        if op in (OP_TYPE_IMAGE, OP_TYPE_SAMPLER, OP_TYPE_SAMPLED_IMAGE, OP_TYPE_ARRAY, OP_TYPE_RUNTIME_ARRAY,
                  OP_TYPE_STRUCT):
            types[ops[0]] = (op, ops[1:])
        elif op == OP_TYPE_POINTER:
            pointers[ops[0]] = (ops[1], ops[2])
        elif op == OP_VARIABLE:
            variables[ops[1]] = (ops[0], ops[2])
        elif op == OP_DECORATE:
            if ops[1] in (DEC_BINDING, DEC_SET):
                decorations.setdefault(ops[0], {})[ops[1]] = i + 3
            struct_decos.setdefault(ops[0], set()).add(ops[1])
        i += count

    def base(type_id):
        while type_id in types and types[type_id][0] in (OP_TYPE_ARRAY, OP_TYPE_RUNTIME_ARRAY):
            type_id = types[type_id][1][0]
        return type_id

    def kind(var):
        sc, pointee = pointers[variables[var][0]]
        t = base(pointee)
        op, operands = types.get(t, (None, ()))
        if op == OP_TYPE_SAMPLER:
            return "sampler"
        if op == OP_TYPE_SAMPLED_IMAGE:
            raise SystemExit("combined image samplers are not supported")
        if op == OP_TYPE_IMAGE:
            sampled = operands[5]  # 1 = sampled, 2 = storage
            return "texture" if sampled == 1 else "storage_texture"
        if sc == SC_STORAGE_BUFFER or (op == OP_TYPE_STRUCT and DEC_BUFFER_BLOCK in struct_decos.get(t, ())):
            return "storage_buffer"
        return "uniform"

    by_set = {}
    for var, decos in decorations.items():
        if var not in variables or DEC_SET not in decos:
            continue
        by_set.setdefault(words[decos[DEC_SET]], []).append((var, kind(var), words[decos[DEC_BINDING]]))

    for set_index, entries in by_set.items():
        if set_index not in (0, 2):
            continue
        textures = sorted(b for _, k, b in entries if k == "texture")
        slots = (max(textures) + 1) if textures else 0
        storage_textures = sorted({b for _, k, b in entries if k == "storage_texture"})
        storage_buffers = sorted({b for _, k, b in entries if k == "storage_buffer"})
        for var, k, b in entries:
            if k == "texture":
                new = 2 * b
            elif k == "sampler":
                new = 2 * b + 1
            elif k == "storage_texture":
                new = 2 * slots + storage_textures.index(b)
            elif k == "storage_buffer":
                new = 2 * slots + len(storage_textures) + storage_buffers.index(b)
            else:
                raise SystemExit(f"unexpected {k} in set {set_index}")
            words[decorations[var][DEC_BINDING]] = new


def post_edit(wgsl):
    wgsl = wgsl.replace("enable clip_distances;\n\n", "").replace("enable clip_distances;\n", "")
    wgsl = re.sub(r"@interpolate\(flat\)", "@interpolate(flat, either)", wgsl)
    # Flat integer varyings carry no explicit interpolate attribute in naga output; WGSL defaults
    # integers to flat(first), which compatibility mode rejects.
    wgsl = re.sub(r"(@location\(\d+\)) (\w+: (?:i32|u32|vec[234]<(?:i32|u32)>))",
                  r"\1 @interpolate(flat, either) \2", wgsl)
    if "clip_distances" in wgsl:
        used = [int(n) for n in re.findall(r"@location\((\d+)\)", wgsl.split("@vertex")[0])]
        free = 0
        while free in used:
            free += 1
        wgsl = re.sub(r"@builtin\(clip_distances\) (\w+): array<f32, 1>", rf"@location({free}) \1: f32", wgsl)
        # The private copy and its stores/loads.
        wgsl = re.sub(r"(var<private> \w*clipDist\w*): array<f32, 1> = array<f32, 1>\(\);", r"\1: f32;", wgsl)
        wgsl = re.sub(r"(\w*clipDist\w*)\[0i\] =", r"\1 =", wgsl)
        if "clip_distances" in wgsl or "array<f32, 1>" in wgsl:
            raise SystemExit("clip distance rewrite left references behind")
    return wgsl


def strip_vertex_input_interp(wgsl):
    lines = wgsl.split("\n")
    for idx, line in enumerate(lines):
        if line.startswith("fn main(") and idx > 0 and lines[idx - 1].strip().startswith("@vertex"):
            head, sep, tail = line.partition(") ->")
            lines[idx] = head.replace(" @interpolate(flat, either)", "") + sep + tail
    return "\n".join(lines)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    data = open(src, "rb").read()
    words = list(struct.unpack(f"<{len(data) // 4}I", data))
    assert words[0] == 0x07230203, "not SPIR-V"
    remap_bindings(words)
    with tempfile.TemporaryDirectory() as tmp:
        spv = os.path.join(tmp, "in.spv")
        out = os.path.join(tmp, "out.wgsl")
        open(spv, "wb").write(struct.pack(f"<{len(words)}I", *words))
        r = subprocess.run(["naga", "--keep-coordinate-space", spv, out], capture_output=True, text=True)
        if r.returncode != 0:
            sys.stderr.write(r.stdout + r.stderr)
            raise SystemExit(r.returncode)
        wgsl = open(out, encoding="utf-8").read()
    wgsl = strip_vertex_input_interp(post_edit(wgsl))
    open(dst, "w", encoding="utf-8", newline="\n").write(wgsl)
    # Round-trip: naga must accept the edited WGSL.
    r = subprocess.run(["naga", dst], capture_output=True, text=True)
    if r.returncode != 0:
        sys.stderr.write(r.stdout + r.stderr)
        raise SystemExit("edited WGSL failed validation")


if __name__ == "__main__":
    main()
