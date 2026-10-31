import struct
import sys


def read_name_table(data):
    count = struct.unpack(">H", data[4:6])[0]
    for i in range(count):
        tag, _, offset, _ = struct.unpack(">4sIII", data[12 + 16 * i:28 + 16 * i])
        if tag == b"name":
            return data[offset:]
    return None


def postscript_name(table):
    count, base = struct.unpack(">HH", table[2:6])
    for i in range(count):
        platform, _, _, name_id, length, offset = struct.unpack(">6H", table[6 + 12 * i:18 + 12 * i])
        if name_id == 6:
            raw = table[base + offset:base + offset + length]
            return raw.decode("utf-16-be" if platform in (0, 3) else "latin-1")
    return None


def main():
    with open(sys.argv[1], "rb") as handle:
        table = read_name_table(handle.read())
    name = postscript_name(table) if table else None
    if not name:
        sys.exit(1)
    print(name)


main()
