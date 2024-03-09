# python version of possible FFT algorithm to be implemented on FPGA

import numpy as np


def num_to_fixed(number, total_bits, fractional_bits):
    max_int = (1 << (total_bits - 1)) - 1
    min_int = -(1 << (total_bits - 1))
    
    if number > max_int:
        number = max_int
    elif number < min_int:
        number = min_int
    
    # Adjust for negative numbers
    if number < 0:
        number += (1 << total_bits)
    
    integer_part = int(number)
    fractional_part = round((number - integer_part) * (1 << fractional_bits))
    
    combined = (integer_part << fractional_bits) | fractional_part
    
    hex_str = hex(combined)[2:]
    
    # If the number of bits in the hex representation is greater than required, trim it
    if len(hex_str) > total_bits // 4:
        hex_str = hex_str[-(total_bits // 4):]
    else:
        hex_str = hex_str.zfill(total_bits // 4)
    
    return hex_str.upper()

# returns binary mirror of num_to_mirror using the num_bits binary representation
def reverse_bits(n, num_bits):
    result = 0
    for i in range(num_bits):
        result <<= 1
        result |= n & 1
        n >>= 1
    return result

# switches numbers of signal around, first step of decimation in time FFT
def decimation(sig):
    N = len(sig)
    num_bits = int(np.log2(N))
    switched_sig = np.zeros(N, dtype=complex)
    for i in range(N):
        switched_sig[i] = sig[reverse_bits(i, num_bits)]
    return switched_sig

def circular_left_shift(num, shift_bits, total_bits):
    # Make sure the shift_bits is within the range of total_bits
    shift_bits %= total_bits
    # Perform the circular left shift
    result = ((num << shift_bits) | (num >> (total_bits - shift_bits))) & ((1 << total_bits) - 1)
    
    return result

def fft_alg(sig):
    sig = np.array(sig)
    n_total = len(sig)
    n_stages = int(np.log2(n_total))

    # fpga needs all twiddle factors generated first
    # below simulates creating a look up table for the values
    twiddle_factors = np.zeros(n_total, dtype=complex)
    for i in range(n_total):
        twiddle_real = np.cos(2*np.pi*i / n_total)
        twiddle_imag = -np.sin(2*np.pi*i / n_total)
        twiddle_factors[i] = twiddle_real + 1j*twiddle_imag
        # print(i, num_to_fixed(twiddle_real, 24, 22), num_to_fixed(twiddle_imag, 24, 22))

    y = decimation(sig) # decimation in time: switch around numbers first
    y_temp = np.zeros(n_total, dtype=complex) # array for holding temporary result
    # outer loop: number of fft stages 
    for stage in range(0, n_stages):
        # 2nd loop: n_total/2 twiddle factor computations per stage
        ndiv2 = int(n_total/2)
        for pair in range(0, ndiv2):
            # generate butterfly address pair
            address = [circular_left_shift(2*pair, stage, n_stages), circular_left_shift(2*pair+ 1, stage, n_stages)]
            # create mask of ones in n_stages-1-stage LSBs
            mask = (1<< (n_stages-1-stage)) - 1
            # perform butterfly operation
            odd_prod = twiddle_factors[pair & ~mask] * y[address[1]]
            y_temp[address[0]] = y[address[0]] + odd_prod
            y_temp[address[1]] = y[address[0]] - odd_prod

        y = y_temp.copy()

    return y


n = 16
# create random signal
signal = np.arange(n)

# numpy fft:
fft_result = np.fft.fft(signal)
print(fft_result)

# custom fft:
fft_result = fft_alg(signal)
print(fft_result)