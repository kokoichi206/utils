SELECT (
	frc.food_receipt_id ,
	frc.food_content_id,
	frc.amount,
	fc.name,
	fc.calories,
	fc.lipid,
	fc.carbohydrate,
	fc.protein
) FROM food_receipt_contents AS frc
INNER JOIN food_contents as fc ON frc.food_content_id = fc.id
WHERE frc.food_receipt_id = '1';

SELECT (
	frc.food_receipt_id as food_receipt_id,
	frc.food_content_id,
	frc.amount,
	fc.name,
	fc.calories,
	fc.lipid,
	fc.carbohydrate,
	fc.protein
) FROM food_receipt_contents
INNER JOIN food_contents ON food_receipt_contents.food_content_id = food_contents.id
WHERE food_receipt_contents.food_receipt_id = '1';

SELECT
	food_receipt_contents.food_receipt_id AS food_receipt_id,
	food_receipt_contents.food_content_id AS food_content_id,
	food_receipt_contents.amount AS amount,
	food_contents.name AS name,
	food_contents.calories AS calories,
	food_contents.lipid AS lipid,
	food_contents.carbohydrate AS carbohydrate,
	food_contents.protein AS protein
FROM food_receipt_contents
INNER JOIN food_contents ON food_receipt_contents.food_content_id = food_contents.id
WHERE food_receipt_contents.food_receipt_id = '1';


SELECT food_receipt_id AS fod_receipt_id
FROM food_receipt_contents
WHERE food_receipt_id = '1';


SELECT
	expenses.id AS id,
	expenses.user_id AS user_id,
	expenses.category_id AS category_id,
	expenses.amount AS amount,
	CASE
		WHEN food_receipts.store_name IS NULL then ''
		ELSE food_receipts.store_name
	END AS store_name,
	expenses.comment AS comment,
	expenses.created_at AS created_at,
	expenses.created_at AS created_at
FROM expenses
LEFT OUTER JOIN food_receipts ON expenses.food_receipt_id = food_receipts.id
INNER JOIN categories ON expenses.category_id = categories.id
WHERE expenses.user_id = 30;


SELECT * FROM sessions
WHERE id = 'e80f63ab-476b-4944-b24d-4e128b3e3c7a' LIMIT 1;
