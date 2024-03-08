# script to generate a "cos_lut.mem", a cosine lookup table in hex format

import math

def to_twos_complement(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return val

def generate_lut_file(lut_points, total_bits, fractional_bits, filename):
    with open(filename, 'w') as f:
        for i in range(lut_points):
            angle = 2 * math.pi * i / lut_points
            cos_val = math.cos(angle)
            scaled_val = cos_val * (2 ** fractional_bits)
            scaled_val = to_twos_complement(int(round(scaled_val)), total_bits)
            f.write("{:0{width}X}\n".format(scaled_val, width=total_bits//4))

lut_points = 8192
total_bits = 24
fractional_bits = 22
filename = "cos_lut.mem"
generate_lut_file(lut_points, total_bits, fractional_bits, filename)
