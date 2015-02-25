def find_address(text)
  # Terrible multi-line regexp
  re = /[ys],\n+.*?\n(.*[A-Z]{2}[0-9]{1,2} ?[0-9]{1}[A-Z]{2})\n/m
  match = text.match re
  match ? match[1] : nil
end