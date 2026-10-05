-- 입장 점검 문항 2 참조 해답
CREATE TABLE book_loans (
    loan_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id     integer NOT NULL REFERENCES books (book_id),
    account_id  integer NOT NULL REFERENCES accounts (account_id),
    loaned_on   date    NOT NULL,
    due_on      date    NOT NULL CHECK (due_on > loaned_on),
    returned_on date    CHECK (returned_on >= loaned_on),
    UNIQUE (account_id, book_id, loaned_on)
);
