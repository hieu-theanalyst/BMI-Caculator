# Requests
# Pandas
# Datetime

# This function gets real-time crypto currency prices every day at 8AM
# It also saves the data as a CSV

import requests 
import pandas as pd 
from datetime import datetime

# API information
url = 'https://api.coingecko.com/api/v3/coins/markets'
param = {
    'vs_currency': 'usd',
    'order': 'market_cap_desc',
    'per_page': 250,
    'page': 1
}

# Sending request
response = requests.get(url, params=param)

if response.status_code == 200: 
    print('Connection Successful! \nGetting the data...') 
    
    # Storing the response into data
    data = response.json()

    # Creating DataFrame
    df = pd.DataFrame(data)
    df = df[[
        'id', 'current_price', 'market_cap', 'price_change_percentage_24h',
        'ath', 'atl'
    ]]

    # Creating a timestamp column
    today = datetime.now().strftime('%d-%m-%Y %H-%M-%S')
    df['time_stamp'] = today

    # Getting Top 10 Negative
    top_negative = df.sort_values(by='price_change_percentage_24h', ascending=True)
    top_negative_10 = top_negative.head(10)
    top_negative_10.to_csv(f'top_negative_10_of_{today}.csv', index=False)

    # Getting Top 10 Positive
    top_positive = df.sort_values(by='price_change_percentage_24h', ascending=False)
    top_positive_10 = top_positive.head(10)
    top_positive_10.to_csv(f'top_positive_10_of_{today}.csv', index=False)

    # Saving full data
    df.to_csv(f'crypto_data_{today}.csv', index=False)

    # Printing summary
    print(f'\nTop 10 Crypto with highest price decrease % on {today}:\n{top_negative_10}')
    print(f'\nTop 10 Crypto with highest price increase % on {today}:\n{top_positive_10}')
    print("\nData saved successfully!")

else: 
    print(f"Connection Failed. Error Code: {response.status_code}")
