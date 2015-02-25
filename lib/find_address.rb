def find_address(text)
  # Terrible multi-line regexp
  re = /y,\n.*?\n(.*[0-9]{2}[A-Z]{2})\n/m
  match = text.match re
  match ? match[1] : nil
end