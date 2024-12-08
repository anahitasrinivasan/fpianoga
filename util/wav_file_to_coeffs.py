import numpy as np
import scipy.io.wavfile as wav
from scipy.fft import fft, fftfreq

def find_harmonic_properties(wav_file, fundamental_freq, num_harmonics=10):
    # Read the wav file
    sample_rate, data = wav.read(wav_file)
    
    # If stereo, take one channel
    if data.ndim > 1:
        data = data[:, 0]
    
    # Perform FFT
    N = len(data)
    fft_values = fft(data)
    freqs = fftfreq(N, d=1/sample_rate)
    
    # Take positive frequencies only
    positive_freqs = freqs[:N//2]
    positive_fft = fft_values[:N//2]  # Complex values for magnitude and phase
    
    # Calculate properties for the fundamental and harmonics
    harmonics = {}
    for i in range(1, num_harmonics + 1):
        target_freq = i * fundamental_freq
        harmonic_index = np.argmin(np.abs(positive_freqs - target_freq))
        
        # Get magnitude and phase
        magnitude = np.abs(positive_fft[harmonic_index])
        phase = np.angle(positive_fft[harmonic_index])  # In radians
        
        harmonics[f"Harmonic {i} ({target_freq:.2f} Hz)"] = {
            "magnitude": magnitude,
            "phase (radians)": phase,
            "phase (degrees)": np.degrees(phase),
        }
    
    return harmonics

# Constants
C4_FREQ = 261.63  # Fundamental frequency of C4 in Hz

# Example usage
wav_file = r"C:\Users\alexi\Downloads\c1_wav_shortened_mixdown.wav"  # Replace with the actual path to your .wav file
harmonics = find_harmonic_properties(wav_file, C4_FREQ)

print("Harmonic Properties:")
for harmonic, properties in harmonics.items():
    print(f"{harmonic}:")
    print(f"  Magnitude: {properties['magnitude']:.2e}")
    print(f"  Phase (radians): {properties['phase (radians)']:.2f}")
    print(f"  Phase (degrees): {properties['phase (degrees)']:.2f}")