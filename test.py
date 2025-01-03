import sqlite3
import sqlite_vec

db = sqlite3.connect(":memory:")
db.enable_load_extension(True)
db.load_extension("./dist/lembed0")
sqlite_vec.load(db)


db.execute("INSERT INTO temp.lembed_models(name, model)  select 'all-MiniLM-L6-v2', lembed_model_from_file('all-MiniLM-L6-v2.e4ce9877.q8_0.gguf');");
#print( db.execute("select lembed_split('all-MiniLM-L6-v2','The United States Postal Service is an independent agency.  The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency.The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency...The United States Postal Service is an independent agency... dima is a good boy',256);").fetchone());
print( db.execute("select lembed_split('all-MiniLM-L6-v2','',256);").fetchone());

