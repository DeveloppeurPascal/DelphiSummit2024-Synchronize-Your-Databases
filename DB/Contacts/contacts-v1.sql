CREATE TABLE contacts (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  name VARCHAR(255) NOT NULL DEFAULT "",
  firstname VARCHAR(255) NOT NULL DEFAULT "",
  phone VARCHAR(255) NOT NULL DEFAULT "",
  email VARCHAR(255) NOT NULL DEFAULT ""
);

CREATE UNIQUE INDEX contacts_email ON contacts
  (email,code);

CREATE UNIQUE INDEX contacts_phone ON contacts
  (phone,code);

CREATE UNIQUE INDEX contacts_name ON contacts
  (name,firstname,code);
