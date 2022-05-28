INSERT INTO food_receipts (store_name) VALUES ('seven') RETURNING *;

INSERT INTO food_contents (
	name,
	calories,
	lipid,
	carbohydrate,
	protein
) VALUES (
	'cola', '225', '0', '55', '0.5'
) RETURNING *;
INSERT INTO food_receipt_contents (
	food_receipt_id,
	food_content_id,
	amount
) VALUES (
	'1', '1', '1'
) RETURNING *;


INSERT INTO expenses (
	user_id,
	category_id,
	amount,
	food_receipt_id,
	comment
) VALUES (
	111,
	$2,
	$3,
	$4,
	$5
) RETURNING *;
