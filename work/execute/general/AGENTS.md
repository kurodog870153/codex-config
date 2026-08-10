# 任務執行規範

## 1. 邊界與載入

1. 只執行已核准 TASK；不得修改 Plan／TASK、改寫需求或擴大成果。
2. TASK、Plan、index 預設位於 `outputs/tasks/<需求編號>.md`、`outputs/plans/<需求編號>.md`、`outputs/executions/<需求編號>/index.md`，共用需求編號；使用者明確指定並確認其他專案相對路徑時才使用該路徑，且三者對應必須一致。Plan 只供名稱對應。
3. 只載入 TASK 基準、目標 TASK、其引用的 `DECISION-*`、index，以及適用的最新 Attempt、承接鏈與 Correction；稽核、衝突或使用者要求時才讀完整歷史。
4. SHA 由工具計算，不把 TASK 全文載入模型；仍可唯讀檢查適用 AGENTS、TASK 範圍內程式碼、產物與工作區。

## 2. 唯讀前置檢查

1. 建立 Attempt 前確認 index 沒有規格鎖、TASK-SPEC 與 SHA 相符、相依 TASK 已完成、必要前序產物實際存在、檔案操作符合現況、工作區差異可解釋且命令入口可用。
2. TASK 為「待執行」或「待重新執行」時可建立新 Attempt；「進行中」只能安全續接 index 所列進行中 Attempt；「受阻」只能在阻礙解除後建立新 Attempt；「已完成」不得執行。
3. 除適用的續接／承接外，「建立」已存在、「修改」不存在，或移動來源／目的不符時，停止並回報規格不符；不得改變操作類型。
4. 既有差異只有路徑與內容均可由核准 TASK、Attempt／Correction、TASK 變更及目前 diff 逐項解釋時，才視為待續接、承接或前序累積成果；不得只依路徑判定，無法確認即停止。
5. 工作區實作差異檢查只排除目前 execution 目錄，不得排除整個 `outputs/`；已核准 CMD 正常產生的非交付暫存輸出不視為實作差異。
6. 前置檢查失敗只在對話回報，不建立 Attempt 或修改 index；下次執行重新檢查。

## 3. Index

1. index 預設位於 `outputs/executions/<需求編號>/index.md`，保存 TASK-SPEC、正規化 TASK SHA、整體狀態及每個 TASK 的單行狀態，不保存更新時間、命令、驗證證據或完整路徑。
2. TASK 狀態只使用「待執行」、「進行中」、「待重新執行」、「受阻」及「已完成」。
3. TASK 行固定包含 TASK ID 與狀態；最新 Attempt、最新 Correction、阻礙或狀態差異原因僅在存在時加入，且只記 ID。
4. 全部待執行時整體為「待執行」；全部必要 TASK 完成時為「已完成」；沒有進行中或可執行 TASK，且未完成項目均受直接或相依阻礙時為「受阻」；其他為「進行中」。
5. 規格鎖存在時不得執行；Execute 不得解除規格鎖。

## 4. 第一次授權與 Attempt 建立

1. 第一次授權摘要列 TASK、目標、適用檔案、步驟、CMD、OP、VAL、影響判斷的風險，以及將建立 Attempt、記錄結果、結案並更新 index；已列項目不需逐行重新詢問。
2. 同一最小 TASK 的多個 OP 可在一次摘要中一併授權；未列入摘要的副作用不得執行。
3. 授權後建立 `ATTEMPT-*`，記狀態、TASK-SPEC、TASK SHA、開始時間；承接成果時另依第 8 節記錄，再將 Attempt 與 index TASK 狀態設為「進行中」。
4. Attempt 預設位於 `outputs/executions/<需求編號>/<TASK-ID>/<ATTEMPT-ID>.md`；每個 TASK 各自由 `ATTEMPT-001` 起編號。
5. 同一 TASK 只能有一個進行中 Attempt；既有 Attempt 必須安全續接或經授權結案。TASK-SPEC 或 SHA 已變更時先結案舊 Attempt，再按新規格建立 Attempt。

## 5. 執行中紀錄

1. 每個 `CMD/OP/VAL` 完成後依實際順序追加一行；同一 ID 重複執行時使用 `#1`、`#2`。
2. CMD 記退出碼與一行關鍵結果，失敗時附最小錯誤；OP 記成功／失敗與必要狀態，不保存完整回應；VAL 記通過／失敗與最小證據，已有證據時引用其 ID。
3. 有檔案修改或承接保留成果時，維護一行「本 Attempt 累積修改檔案」，列出承接與目前 Attempt 的累積聯集路徑，不保存 diff 或雜湊。
4. 只能修改 TASK 明列檔案並執行明列 `CMD/OP`，需要額外項目時立即停止；實際命令與 `CMD-*` 不同時須先取得使用者授權，再記錄完整命令與原因。
5. 第一次非預期失敗立即停止，不得自行修正、改用其他命令或重試。

## 6. 停止與受阻

1. Attempt 狀態只使用「進行中」、「已完成」、「已停止」及「受阻」。
2. 「受阻」只用於 TASK 範圍外且本次無法解除的前置條件，類型為環境、外部服務、權限、必要輸入或其他；「已停止」用於執行後異常結束，類型為規格缺陷、驗證失敗、未預期變更、使用者停止或其他。
3. 結案時只在適用時加入類型與具體原因；「其他」限無固定類型可用。
4. Attempt 與 TASK 狀態固定對應：進行中→進行中、已完成→已完成、一般已停止→待重新執行、規格缺陷已停止→受阻、受阻→受阻；規格缺陷只停止並交接 task 流程，不得修改 TASK。
5. 外部阻礙解除後，可在新授權中直接建立 Attempt 並設為「進行中」；不先單獨改為「待重新執行」。
6. Attempt 結案且留下修改時保留累積修改檔案，供後續承接核對。

## 7. 結案與回報

1. 完成、停止或受阻後，加入結束時間、按實際結果更新 Attempt 與 index，再回報結果、修改檔案、CMD／OP／VAL 摘要及剩餘風險。
2. 結案後 Attempt 不可修改或增加重複摘要欄；時間使用 24 小時制 `YYYY-MM-DDTHH:mm±HH:mm`，進行中只記開始，結案再加結束。

## 8. 續接、承接與 Correction

1. 本節只在 index 或使用者要求符合情境時適用；不得藉此改寫 TASK 或擴大成果。
2. 續接進行中 Attempt 前，唯讀核對工作區與紀錄；無法逐項解釋既有成果時停止。
3. 承接只指向同一 TASK 的最新已結案 Attempt，不得跳過或循環；複製其已核對累積修改檔案。只有目標 `CMD/OP/VAL` 已完成、現況仍符合 TASK 且未被規格變更失效時，才記 `承接 <ID>：<ATTEMPT-ID>/<ID>` 並免重做；證據不足則依目前 TASK 執行，若與保留成果衝突即回報規格不符。
4. 更正須獨立授權；只建立同目錄的 `<ATTEMPT-ID>-CORRECTION-001` 並更新 index，不修改 TASK、實作或原 Attempt。內容限建立時間、目標、欄位、正確值、原因及必要證據；寫入後不可修改，再次更正取下一號。
5. Correction 使完成狀態失效時，目標及已完成下游 TASK 改為「待重新執行」；只有 TASK 狀態與最新 Attempt 結果不一致時，index 才記原因。

## 9. 完成

1. TASK 只有全部適用 VAL 通過才能標記「已完成」。
2. 所有必要 TASK 已完成即代表 Plan 驗收已有 Attempt 證據；不重讀全部 Attempt 或建立 `completion.md`。

## 10. 最小骨架

1. 下列為唯一欄位名稱與順序；`<占位符>` 必須替換，不得輸出。選用欄位沒有內容時整行省略，不得新增同義欄位。
2. 跨文件值不得自行改寫：TASK-SPEC 與 TASK ID 取自正式 TASK，TASK-SHA-256 依第 1 節計算，`CMD/OP/VAL/DECISION` ID 必須存在於目標 TASK，Attempt／Correction ID 必須符合檔案路徑及 index。

### 10.1 Index

```markdown
# Execution

TASK-SPEC：TASK-SPEC-001
TASK-SHA-256：<sha>
整體狀態：待執行

TASK-001：待執行
```

1. `規格鎖：更新中` 僅由 plan／task 流程建立，固定放在 TASK-SHA-256 與整體狀態之間。
2. 每個 TASK 固定一行並依 TASK 文件順序排列；選用欄位順序固定如下：

```markdown
TASK-001：<TASK 狀態>；最新 Attempt：<ATTEMPT-ID>；最新 Correction：<CORRECTION-ID>；阻礙：<TASK-ID 或 ATTEMPT-ID>；狀態差異原因：<CORRECTION-ID 或 TASK-CHANGE-ID>
```

3. TASK 行只保留實際存在的選用欄位；不得輸出占位符或空欄位。

### 10.2 Attempt 建立

```markdown
# ATTEMPT-001

狀態：進行中
TASK-SPEC：TASK-SPEC-001
TASK-SHA-256：<sha>
開始：YYYY-MM-DDTHH:mm±HH:mm
```

### 10.3 承接 Attempt

```markdown
# ATTEMPT-002

狀態：進行中
TASK-SPEC：TASK-SPEC-002
TASK-SHA-256：<sha>
開始：YYYY-MM-DDTHH:mm±HH:mm
承接：ATTEMPT-001
本 Attempt 累積修改檔案：`<path>`、`<path>`
承接 CMD-001：ATTEMPT-001/CMD-001；<目前現況仍符合 TASK 的最小證據>
承接 OP-001：ATTEMPT-001/OP-001；<目前現況仍符合 TASK 的最小證據>
承接 VAL-001：ATTEMPT-001/VAL-001；<目前現況仍符合 TASK 的最小證據>
```

1. `承接` 後依序放累積修改檔案及實際承接且仍有效的 `CMD/OP/VAL`；沒有適用項目時省略對應行。

### 10.4 執行紀錄

依實際發生順序追加，格式固定如下：

```markdown
CMD-001：退出碼 <code>；<一行關鍵結果或最小錯誤>
OP-001：<成功或失敗>；<一行必要狀態>
VAL-001：<通過或失敗>；<最小證據或已足夠的前項 ID>
```

1. 同一 ID 重複執行時依序使用 `CMD-001#1`、`CMD-001#2`；`OP/VAL` 相同。
2. 「本 Attempt 累積修改檔案」固定放在開始／承接欄位之後、第一筆執行紀錄之前；沒有修改時省略。

### 10.5 Attempt 結案

1. 完成時將頂部狀態改為「已完成」，並在最後一筆執行紀錄後加入：

```markdown
結束：YYYY-MM-DDTHH:mm±HH:mm
```

2. 停止時將頂部狀態改為「已停止」，並在最後一筆執行紀錄後依序加入：

```markdown
類型：<規格缺陷、驗證失敗、未預期變更、使用者停止或其他>
原因：<具體原因>
結束：YYYY-MM-DDTHH:mm±HH:mm
```

3. 受阻時將頂部狀態改為「受阻」，並在最後一筆執行紀錄後依序加入：

```markdown
類型：<環境、外部服務、權限、必要輸入或其他>
原因：<具體原因>
結束：YYYY-MM-DDTHH:mm±HH:mm
```

### 10.6 Correction

```markdown
# ATTEMPT-001-CORRECTION-001

建立：YYYY-MM-DDTHH:mm±HH:mm
目標：ATTEMPT-001
欄位：<被更正欄位>
正確值：<值>
原因：<原因及必要證據>
```
