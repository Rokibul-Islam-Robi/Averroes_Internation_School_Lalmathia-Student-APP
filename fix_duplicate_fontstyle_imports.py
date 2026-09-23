"""
fix_duplicate_fontstyle_imports.py

সমস্যা:
  বেশিরভাগ .dart ফাইলে `wireframe_fontstyle.dart` ২-৩ বার import করা হয়েছে
  (একবার package path দিয়ে, একবার relative path দিয়ে) - এই দুটো একই ফাইল
  হওয়া সত্ত্বেও analyzer দুইবার আলাদা import হিসেবে দেখে, তাই duplicate_import
  warning দেয়। আবার কিছু ফাইলে সেই import আদৌ ব্যবহারই হয় না (sanspro... স্টাইল
  কোথাও নেই), তখন unused_import warning ও আসে।

এই স্ক্রিপ্ট কী করে:
  ১) lib/ ফোল্ডারের ভেতরে থাকা সব .dart ফাইল খুঁজে বের করে।
  ২) প্রতিটা ফাইলে wireframe_fontstyle.dart এর import লাইন যতবারই থাকুক
     (package path বা relative path — যেকোনো ফর্মে), প্রথমটা রেখে বাকিগুলো
     ফেলে দেয় (duplicate_import ফিক্স)।
  ৩) এরপর চেক করে ফাইলের বাকি অংশে (import লাইন বাদে) `sanspro` শব্দটা
     (sansproRegular / sansproBold / sansproSemibold) আছে কিনা।
       - না থাকলে বুঝে নেয় import টা আসলে দরকারই নেই, এবং বেঁচে থাকা
         শেষ import লাইনটাও মুছে দেয় (unused_import ফিক্স)।
       - থাকলে ১টা import রেখে দেয়।

কীভাবে চালাবেন (Terminal / Command Prompt / PowerShell থেকে):
  ১. এই ফাইলটা আপনার প্রজেক্টের রুটে রাখুন (যেখানে pubspec.yaml আছে, তার পাশে)।
  ২. প্রজেক্ট রুট থেকে চালান:

        python fix_duplicate_fontstyle_imports.py

     অথবা যদি শুধু "python" কাজ না করে:

        python3 fix_duplicate_fontstyle_imports.py

  ৩. স্ক্রিপ্ট চলা শেষে টার্মিনালে দেখাবে কোন কোন ফাইল বদলেছে এবং কী অ্যাকশন
     নিয়েছে (dedup করে ১টা রাখা হয়েছে, নাকি পুরোপুরি সরানো হয়েছে)।
  ৪. এরপর `flutter pub get` চালিয়ে `flutter analyze` দিয়ে চেক করে নিন।

নিরাপত্তা:
  - স্ক্রিপ্টটা শুধু wireframe_fontstyle.dart এর import লাইন নিয়ে কাজ করে,
    অন্য কোনো import বা কোড টাচ করে না।
  - চালানোর আগে চাইলে গোটা lib/ ফোল্ডারটা কপি করে ব্যাকআপ রেখে দিতে পারেন
    (ঝুঁকি নেই তবুও সাবধানতা ভালো)।
"""

import os
import sys

# প্রজেক্ট রুট থেকে lib ফোল্ডারের path (স্ক্রিপ্টটা রুটে রেখে চালালে এটাই ঠিক থাকবে)
LIB_DIR = "lib"


def is_fontstyle_import(line: str) -> bool:
    stripped = line.strip()
    if not stripped.startswith("import"):
        return False
    return "wireframe_fontstyle.dart'" in line or 'wireframe_fontstyle.dart"' in line


def process_file(path: str):
    with open(path, "r", encoding="utf-8", newline="") as f:
        content = f.read()

    lines = content.split("\n")
    out_lines = []
    seen_fontstyle = False
    fontstyle_line_idx = None
    removed_count = 0

    for line in lines:
        if is_fontstyle_import(line):
            if not seen_fontstyle:
                seen_fontstyle = True
                fontstyle_line_idx = len(out_lines)
                out_lines.append(line)
            else:
                removed_count += 1
                continue  # duplicate -> skip
        else:
            out_lines.append(line)

    if not seen_fontstyle:
        return None  # এই ফাইলে fontstyle import নেই, কিছু করার নেই

    body_text = "\n".join(l for l in out_lines if not l.strip().startswith("import"))
    used = "sanspro" in body_text.lower()

    if not used:
        del out_lines[fontstyle_line_idx]
        removed_count += 1
        action = "সম্পূর্ণ import সরানো হয়েছে (unused)"
    else:
        action = f"{removed_count} টা duplicate সরিয়ে ১টা import রাখা হয়েছে"

    new_content = "\n".join(out_lines)
    if new_content != content:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(new_content)
        return action
    return None


def main():
    if not os.path.isdir(LIB_DIR):
        print(f"'{LIB_DIR}' ফোল্ডার পাওয়া যায়নি। এই স্ক্রিপ্টটা প্রজেক্টের রুটে "
              f"(pubspec.yaml যেখানে আছে) রেখে চালান।")
        sys.exit(1)

    changed = 0
    for root, _, files in os.walk(LIB_DIR):
        for fname in files:
            if not fname.endswith(".dart"):
                continue
            fpath = os.path.join(root, fname)
            result = process_file(fpath)
            if result:
                changed += 1
                print(f"[FIXED] {fpath} -> {result}")

    print(f"\nমোট {changed} টা ফাইল ঠিক করা হয়েছে।")


if __name__ == "__main__":
    main()
