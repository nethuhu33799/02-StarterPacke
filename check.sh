#!/usr/bin/env bash
#
# check.sh — ตรวจความถูกต้องของบรรทัด TEAM ใน index.html
#
# วิธีใช้:
#   ./check.sh            # คาดหวังอย่างน้อย 1 ชื่อ
#   ./check.sh 4          # คาดหวังอย่างน้อย 4 ชื่อ (ทีม 4 คน)
#
# ตรวจ 4 อย่าง:
#   1) ไม่มี conflict marker ค้าง (<<<<<<<, =======, >>>>>>>)
#   2) ไม่มีข้อความ placeholder ในวงเล็บ
#   3) เจอบรรทัด TEAM และมีชื่อจริง
#   4) จำนวนชื่อ (คั่นด้วย comma) >= ค่าที่คาดหวัง
#
# feedback เป็น "ทิศทาง" บอกว่าขาดอะไร ไม่ใช่แค่ผ่าน/ไม่ผ่าน

set -u

FILE="index.html"
EXPECTED="${1:-1}"

# ---------- helper สีและสัญลักษณ์ ----------
PASS="✅"
FAIL="❌"
INFO="👉"
problems=0

note() { printf '%s %s\n' "$INFO" "$1"; }
ok()   { printf '%s %s\n' "$PASS" "$1"; }
bad()  { printf '%s %s\n' "$FAIL" "$1"; problems=$((problems + 1)); }

echo "==================================================="
echo "  ตรวจงาน: $FILE  (คาดหวังอย่างน้อย $EXPECTED ชื่อ)"
echo "==================================================="

# ---------- 0) มีไฟล์ไหม ----------
if [ ! -f "$FILE" ]; then
  bad "ไม่พบไฟล์ $FILE — รัน script นี้ในโฟลเดอร์ root ของ repo (ที่มี index.html)"
  echo "---------------------------------------------------"
  exit 1
fi

# ---------- 1) conflict marker ----------
if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$FILE"; then
  bad "ยังมี conflict marker ค้างอยู่ในไฟล์ — ต้องลบบรรทัดที่ขึ้นต้นด้วย <<<<<<< , ======= , >>>>>>> ออกให้หมด"
  note "บรรทัดที่มีปัญหา:"
  grep -nE '^(<<<<<<<|=======|>>>>>>>)' "$FILE" | sed 's/^/      /'
else
  ok "ไม่มี conflict marker ค้าง"
fi

# ---------- 2) หาบรรทัด TEAM ----------
team_line="$(grep 'id="team"' "$FILE" | head -n 1)"

if [ -z "$team_line" ]; then
  bad "หาบรรทัด TEAM (id=\"team\") ไม่เจอ — เผลอลบบรรทัดเป้าหมายไปหรือเปล่า?"
  echo "---------------------------------------------------"
  echo "สรุป: ยังไม่ผ่าน ($problems จุดต้องแก้)"
  exit 1
fi

# ---------- 3) placeholder ----------
if printf '%s' "$team_line" | grep -q '(คน'; then
  bad "ยังมีข้อความ placeholder ในวงเล็บ '(คน 1 ใส่ชื่อ...)' เหลืออยู่ — คน 1 ต้องลบออกแล้วใส่ชื่อจริง"
else
  ok "ไม่มีข้อความ placeholder ค้าง"
fi

# ---------- 4) ดึงรายชื่อหลัง "ทีมผู้บริหาร:" ----------
# ตัดเอาเฉพาะส่วนหลัง ':' และก่อน '</p>'
names_part="$(printf '%s' "$team_line" | sed -E 's/.*ทีมผู้บริหาร:[[:space:]]*//; s/<\/p>.*//')"

# นับชื่อที่คั่นด้วย comma (ตัดช่องว่างและช่องว่างล้วนทิ้ง)
count=0
named_list=""
IFS=','
for raw in $names_part; do
  name="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  if [ -n "$name" ] && ! printf '%s' "$name" | grep -q '(คน'; then
    count=$((count + 1))
    named_list="${named_list}  ${count}) ${name}\n"
  fi
done
unset IFS

echo "---------------------------------------------------"
if [ "$count" -gt 0 ]; then
  note "พบชื่อ $count คนบนบรรทัด TEAM:"
  printf '%b' "$named_list"
else
  note "ยังไม่พบชื่อใดๆ บนบรรทัด TEAM"
fi

if [ "$count" -ge "$EXPECTED" ]; then
  ok "จำนวนชื่อครบตามที่คาดหวัง ($count/$EXPECTED)"
else
  missing=$((EXPECTED - count))
  bad "ชื่อยังไม่ครบ: มี $count คน ต้องการ $EXPECTED คน — ขาดอีก $missing คน"
  note "ถ้าเพิ่ง resolve conflict มา ให้เช็คว่าทำชื่อใครหายไปหรือเปล่า (ต้องเก็บทุกชื่อ ต่อท้ายด้วย comma)"
fi

# ---------- สรุป ----------
echo "==================================================="
if [ "$problems" -eq 0 ]; then
  echo "$PASS ผ่านครบทุกข้อ — ลงชื่อทีมงานเรียบร้อย ปิดงานได้เลย 🎉"
  exit 0
else
  echo "$FAIL ยังไม่ผ่าน — มี $problems จุดที่ต้องแก้ (อ่าน $INFO ด้านบนว่าขาดอะไร)"
  exit 1
fi
