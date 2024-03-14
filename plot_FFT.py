import numpy as np
import matplotlib.pyplot as plt

#### fft data from testbench #####
data = np.genfromtxt('fft_output.txt', delimiter=',', dtype=np.int64)
# Convert to fixed-point representation with 23 fractional bits
fixed_point_data = data / (1 << 23)
# Separate real and imaginary parts
real_part_tb = fixed_point_data[:, 0]
imaginary_part_tb = fixed_point_data[:, 1]

##### compute fft in python #####
# test signal, same is generated in fpga testbench
N = 16
signal = np.zeros(1024)
for i in range(1024):
    if (i//N) % 2 == 0:
        signal[i] = 0.5
    else:
        signal[i] = -0.5

fft_signal = np.fft.fft(signal)
real_part_np = fft_signal.real
imaginary_part_np = fft_signal.imag

# Plot original signal
plt.figure(figsize=(10, 5))
plt.plot(signal)
plt.xlabel('Index')
plt.ylabel('Value')
plt.title('Original Signal')
plt.grid(True)
plt.show()

# create 4 panel plot
plt.figure(figsize=(15, 10))

# Plot real part from testbench
plt.subplot(2, 2, 1)
plt.plot(real_part_tb)
plt.xlabel('Index')
plt.ylabel('Real Value')
plt.title('Real Part (Testbench)')
plt.grid(True)

# Plot real part from python
plt.subplot(2, 2, 2)
plt.plot(real_part_np)
plt.xlabel('Index')
plt.ylabel('Real Value')
plt.title('Real Part (Python)')
plt.grid(True)

# Plot imaginary part from testbench
plt.subplot(2, 2, 3)
plt.plot(imaginary_part_tb)
plt.xlabel('Index')
plt.ylabel('Imaginary Value')
plt.title('Imaginary Part (Testbench)')
plt.grid(True)

# Plot imaginary part from python
plt.subplot(2, 2, 4)
plt.plot(imaginary_part_np)
plt.xlabel('Index')
plt.ylabel('Imaginary Value')
plt.title('Imaginary Part (Python)')
plt.grid(True)

plt.tight_layout()  
plt.show()