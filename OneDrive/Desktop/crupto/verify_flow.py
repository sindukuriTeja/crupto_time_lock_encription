import sys
import os

# Add the current directory to the path so we can import the modules
sys.path.append(os.path.join(os.getcwd(), 'time_lock_crypto'))

from time_lock_crypto.crypto.rsa_utils import generate_rsa_keys, rsa_encrypt, rsa_decrypt
from time_lock_crypto.crypto.aes_utils import aes_encrypt, aes_decrypt
from time_lock_crypto.crypto.puzzle import generate_puzzle, solve_puzzle
from time_lock_crypto.crypto.integrity import compute_hash
from time_lock_crypto.crypto.compression import compress_data, decompress_data
from Crypto.Random import get_random_bytes

def test_full_flow():
    print("Starting verification...")
    
    # 1. Setup
    sender_id = "Alice"
    receiver_id = "Bob"
    message = "This is a secret message for verification."
    print(f"Original Message: {message}")
    
    # 2. Encryption Side
    print("Encrypting...")
    private, public = generate_rsa_keys()
    
    # Inner Layer (Data -> AES)
    session_key = get_random_bytes(16)
    data_nonce = get_random_bytes(12)
    
    message_hash = compute_hash(sender_id, receiver_id, data_nonce, message)
    payload = message.encode() + message_hash + data_nonce
    
    compressed_payload = compress_data(payload)
    _, data_ct, data_tag = aes_encrypt(session_key, compressed_payload, nonce=data_nonce)
    
    # RSA Layer (Session Key -> RSA)
    enc_session_key = rsa_encrypt(public, session_key)
    
    # Outer Layer (RSA Key -> AES -> Puzzle)
    puzzle_key = get_random_bytes(16)
    puzzle_nonce = get_random_bytes(12)
    _, key_ct, key_tag = aes_encrypt(puzzle_key, enc_session_key, nonce=puzzle_nonce)
    
    # Time lock
    t = 1000 # Low difficulty for testing
    n, a, t, locked_puzzle_key = generate_puzzle(puzzle_key, t)
    print("Encryption and Locking complete.")
    
    # 3. Decryption Side
    print("Decrypting...")
    
    # Solve puzzle
    recovered_puzzle_key = solve_puzzle(n, a, t, locked_puzzle_key)
    assert recovered_puzzle_key == puzzle_key, "Puzzle solution failed! Keys do not match."
    print("Puzzle solved, puzzle key recovered.")
    
    # Decrypt Outer Layer
    recovered_enc_session_key = aes_decrypt(recovered_puzzle_key, puzzle_nonce, key_ct, key_tag)
    
    # Decrypt RSA Layer
    recovered_session_key = rsa_decrypt(private, recovered_enc_session_key)
    assert recovered_session_key == session_key, "RSA decryption failed! Session keys do not match."
    print("RSA decrypted, session key recovered.")
    
    # Decrypt Inner Layer
    recovered_compressed_payload = aes_decrypt(recovered_session_key, data_nonce, data_ct, data_tag)
    
    # Decompress
    recovered_payload = decompress_data(recovered_compressed_payload)
    
    # Extract
    nonce_rec = recovered_payload[-12:]
    hash_rec = recovered_payload[-44:-12]
    plain_msg_bytes = recovered_payload[:-44]
    plain_msg = plain_msg_bytes.decode()
    
    print(f"Decrypted Message: {plain_msg}")
    
    # Verify
    assert plain_msg == message, "Decrypted message does not match original!"
    
    computed_hash = compute_hash(sender_id, receiver_id, nonce_rec, plain_msg)
    assert computed_hash == hash_rec, "Integrity check failed!"
    
    print("Verification SUCCESS!")

if __name__ == "__main__":
    test_full_flow()
