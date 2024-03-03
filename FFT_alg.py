# python version of possible FFT algorithm to be implemented on FPGA

import numpy as np

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

def fft_alg(sig):
    sig = np.array(sig)
    n_total = len(sig)
    n_stages = int(np.log2(n_total))

    # fpga needs all twiddle factors generated first
    # below simulates creating a look up table for the values
    twiddle_factors = np.zeros(n_total, dtype=complex)
    for i in range(n_total):
        twiddle_real = np.cos(2*np.pi*i / n_total)
        twiddle_imag = np.sin(2*np.pi*i / n_total)
        twiddle_factors[i] = twiddle_real - 1j*twiddle_imag

    y = decimation(sig) # decimation in time: switch around numbers first
    y_temp = np.zeros(n_total, dtype=complex) # array for holding temporary result
    # first loop: number of fft stages 
    for stage in range(1, n_stages + 1):
        n = 2**stage # sub fft size, starts at 2

        # 2nd loop: iterations = number of sub ffts 
        # n_total/2 ... 4, 2, 1 = n_total/n
        for sub_fft in range(0, int(n_total/n)):
            # index offset of sub fft depends on sub fft size and iteration
            offset = sub_fft * n
            # for each sub fft, there are n/2 number of twiddle factors
            ndiv2 = int(n/2)
            for i in range(0, ndiv2):
                odd_prod = twiddle_factors[int((n_total/n) * i)] * y[offset + i + ndiv2]
                y_temp[offset + i] = y[offset + i] + odd_prod
                y_temp[offset + i + ndiv2] = y[offset + i] - odd_prod

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


