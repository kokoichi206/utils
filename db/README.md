## setup
``` sh
docker run --name postgres12 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=account -d postgres:12-alpine
docker exec -it postgres12 createdb --username=root --owner=root account_book
docker exec -it postgres12 dropdb account_book
```

### example
- [sql query](./sql_examples)
