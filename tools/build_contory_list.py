import pandas as pd
import os

path = "assets/image/territories"

files = [f for f in os.listdir(path) if f.endswith(".png")]

records = []

for i,f in enumerate(files):
	name = f.split(".")[0].split("_")[1]
	records.append({"id": i, "name": name, "texture": f"res://{path}/{f}"})

df = pd.DataFrame(records)

df.to_csv("data/csv/territories.csv", index=False)