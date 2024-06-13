CREATE TABLE todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  label VARCHAR(255) NULL DEFAULT "",
  done BIT NULL DEFAULT 0
);

CREATE UNIQUE INDEX par_label ON todos
  (label,id);

CREATE UNIQUE INDEX par_done_label ON todos
  (done,label,id);
