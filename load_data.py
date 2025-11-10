import pandas as pd
from sqlalchemy import create_engine
import json
import ast
import os

# Connecting to the MySQL database
engine = create_engine(os.getenv("credentials"))

tracks_df = pd.read_csv(r"C:\Users\Jason\Downloads\tracks.csv")
artists_df = pd.read_csv(r"C:\Users\Jason\Downloads\artists.csv")

# Cleaning list elements into valid JSON arrays so MySQL can parse them correctly
def fix_json_column(series):
    """Ensure JSON columns contain valid JSON arrays."""
    def clean_value(x):
        if pd.isna(x) or x == '':
            return '[]'
        if isinstance(x, str):
            try:
                parsed = ast.literal_eval(x)
                return json.dumps(parsed)
            except (ValueError, SyntaxError):
                try:
                    parsed = json.loads(x)
                    return json.dumps(parsed)
                except:
                    return json.dumps([x])
        return json.dumps(x)
    return series.apply(clean_value)

tracks_df["id_artists"] = fix_json_column(tracks_df["id_artists"])
artists_df["genres"] = fix_json_column(artists_df["genres"])

# Upload to MySQL staging tables
tracks_df.to_sql("stg_spotify_tracks", con=engine, if_exists="append", index=False)
artists_df.to_sql("stg_spotify_artists", con=engine, if_exists="append", index=False)

print("Data successfully loaded into staging tables!")
