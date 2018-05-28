# frozen_string_literal: true

require 'base64'
require_relative 'securable'

# Security Primitives for Database
class SecureDB
  
  extend Securable
  
  # Encrypt or else return nil if data is nil
  def self.encrypt(plaintext)
    return nil unless plaintext
    ciphertext = base_encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  end
  
  # Decrypt or else return nil if database value is nil  already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64 
    ciphertext = Base64.strict_decode64(ciphertext64)
    base_decrypt(ciphertext)
  end
  
  
  # PasswordHash - generate salt
  def self.new_salt
    Base64.strict_encode64(
      RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    )
  end
  
  # PasswordHash
  def self.hash_password(salt, pwd)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64
    digest = RbNaCl::PasswordHash.scrypt(pwd, Base64.strict_decode64(salt),
                                         opslimit, memlimit, digest_size)
    Base64.strict_encode64(digest)
  end
  
  def self.hash_sha256(message)
    digest = RbNaCl::Hash.sha256(message)
    Base64.strict_encode64(digest)
  end
end
