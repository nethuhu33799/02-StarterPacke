# 💻 docs/COMMANDS.md — ชุดคำสั่งพิมพ์ตามได้เลย

> วิธีใช้: แทนที่ `<...>` ด้วยค่าจริงของคุณ
> - `<ชื่อ>` = ชื่อตัวเอง (ตัวอักษรอังกฤษ ไม่เว้นวรรค) เช่น `michael`
> - `<URL-repo>` = ลิงก์ repo ของทีม (เอามาจากปุ่ม Code สีเขียวบน GitHub)
> - `<คน1>` = ชื่อหัวหน้าทีมที่ seed ลง main ไว้แล้ว
>
> ⛔ ในเวิร์กช็อปนี้ **ไม่ใช้** `fork`, `rebase`, `cherry-pick` — ใช้เฉพาะคำสั่งในไฟล์นี้เท่านั้น

---

## 🎩 สำหรับคน 1 (หัวหน้า) — seed ชื่อลง main

คน 1 **ไม่ต้อง clone ไม่ต้องเปิด PR** ทำบนเว็บ GitHub ได้เลย:

1. เปิดไฟล์ `index.html` บน GitHub → กดปุ่มดินสอ ✏️ (Edit)
2. หาบรรทัดที่มี `<!-- TEAM -->`
3. แก้จาก
   ```
   ทีมผู้บริหาร: (คน 1 ใส่ชื่อตัวเองที่นี่ก่อน)
   ```
   เป็น
   ```
   ทีมผู้บริหาร: <คน1>
   ```
4. เลื่อนลงล่าง → **Commit changes** → เลือก **"Commit directly to the `main` branch"**

---

## 🔫 สำหรับคน 2, 3, 4 (ลูกน้อง) — ตั้งแต่ clone จนเปิด PR

### STEP 1 — clone repo ลงเครื่อง
```bash
git clone <URL-repo>
cd <ชื่อโฟลเดอร์ที่ clone มา>
```

### STEP 2 — สร้าง branch ของตัวเอง แล้วสลับเข้าไป
```bash
git switch -c add-name-<ชื่อ>
```

### STEP 3 — แก้ index.html (เฉพาะบรรทัด TEAM)
เปิด `index.html` ด้วย editor แล้วต่อชื่อตัวเองท้ายบรรทัด `<!-- TEAM -->` คั่นด้วย comma

ตัวอย่าง: ถ้าบน main มี `ทีมผู้บริหาร: <คน1>` ให้แก้เป็น
```
ทีมผู้บริหาร: <คน1>, <ชื่อ>
```
> ✅ ต่อท้ายเท่านั้น — ❌ ห้ามลบชื่อ `<คน1>` และห้ามแก้บรรทัดอื่น

### STEP 4 — stage + commit
```bash
git add index.html
git commit -m "add name <ชื่อ> to team line"
```

### STEP 5 — push branch ขึ้น GitHub
```bash
git push -u origin add-name-<ชื่อ>
```

### STEP 6 — เปิด Pull Request
- ไปที่ repo บน GitHub → จะมีปุ่ม **"Compare & pull request"** เด้งขึ้นมา → กด
- ตรวจให้แน่ใจว่า **base = `main`** และ **compare = `add-name-<ชื่อ>`**
- กด **Create pull request**
- ⏸️ **หยุดแค่นี้** — ยังไม่ merge รอจนทุกคนเปิด PR ครบ แล้วไป approve ให้เพื่อน

---

## 🧨 ชุด RESOLVE CONFLICT (สำหรับคน 3 และ 4 เมื่อ merge แล้วชน)

> ทำเมื่อ GitHub บอกว่า **"This branch has conflicts that must be resolved"**
> 📣 **แจ้งใน Issue หลักก่อนเริ่มแก้** เพื่อกันคนอื่นแก้ชนกัน

### STEP R1 — กลับมาที่ branch ของตัวเอง แล้วดึง main ล่าสุดลงมารวม
```bash
git switch add-name-<ชื่อ>
git pull origin main
```
จะเห็นข้อความว่า `CONFLICT (content): Merge conflict in index.html` — **ปกติ ไม่ต้องตกใจ**

### STEP R2 — เปิด index.html แก้ marker ด้วยมือ
จะเจอหน้าตาแบบนี้:
```
<<<<<<< HEAD
<!-- TEAM --> <p id="team">ทีมผู้บริหาร: <คน1>, <ชื่อ></p>
=======
<!-- TEAM --> <p id="team">ทีมผู้บริหาร: <คน1>, <ชื่อคนที่ merge ไปก่อน></p>
>>>>>>> ...
```
**รวมชื่อทุกคนให้เหลือบรรทัดเดียว แล้วลบ 3 บรรทัด marker ออกให้หมด** (`<<<<<<<`, `=======`, `>>>>>>>`):
```
<!-- TEAM --> <p id="team">ทีมผู้บริหาร: <คน1>, <ชื่อคนที่ merge ไปก่อน>, <ชื่อ></p>
```
> 🎯 ห้ามทิ้งชื่อใคร — ทุกชื่อต้องอยู่ครบบนบรรทัดเดียว

### STEP R3 — stage + commit (commit นี้คือการ "ปิด" การ merge)
```bash
git add index.html
git commit -m "resolve conflict: keep all names on team line"
```

### STEP R4 — push ขึ้นไป แล้ว PR จะหายชนเอง
```bash
git push
```
กลับไปดู PR บน GitHub — ปุ่ม **Merge** จะกดได้แล้ว → merge ได้เลย

---

## 🔍 ตรวจงานตัวเอง (ทำได้ทุกเมื่อ)
```bash
./check.sh 4
```
(เปลี่ยน `4` เป็นจำนวนคนในทีม) — script จะบอกว่าขาดอะไรบ้าง
