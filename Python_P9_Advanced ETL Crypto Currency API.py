# this application will fetch crypto currency data from coingeko site
# find top 10 to sell 
# find bottom 10 to buy
# send mail to me everyday at 8AM

# task
# 1. download the datasets from the coingeko
# 2. send mail
# 3. schedule task 8am


# Importing Dependencies
import smtplib # For sending emails
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
import email.encoders

import requests # For making HTTP requests to APIs
import schedule # For scheduling tasks
from datetime import datetime # For timestamping
import time
import pandas as pd # For working with tabular data

from dotenv import load_dotenv
import os

load_dotenv() # Loads sensitive credentials (EMAIL_USER, EMAIL_PASS) from a .env file.

def send_mail(subject, body, filename):
    
    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    sender_mail = os.getenv("EMAIL_USER")
    email_password = os.getenv("EMAIL_PASS")
    receiver_mail = "hieuminhduong.work@gmail.com"

    # Compose The Mail
    message = MIMEMultipart()
    message['From'] = sender_mail
    message['To'] = receiver_mail
    message ['Subject'] = subject
    
    # Attaching Body
    message.attach(MIMEText(body, 'plain'))
    
    # Attach csv file
    with open(filename, 'rb') as file:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(file.read())
        email.encoders.encode_base64(part)  # This line encodes the file in base64 (optional)
        part.add_header('Content-Disposition', f'attachment; filename="{filename}"')
        message.attach(part)
        
        
    # Start Server
    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls() #secure connection
            server.login(sender_mail, email_password) #login
            
            # Sending Mail
            server.sendmail(sender_mail, receiver_mail, message.as_string())
            print("Email sent successfully!")
        
    except Exception as e:
        print(f'Unable to send mail {e}')


# Getting Crypto Data
def get_crypto_data():
    # API Information
    url = 'https://api.coingecko.com/api/v3/coins/markets' # CoinGecko endpoint for current market data.
    param = {
        'vs_currency' : 'usd', # Get prices in USD.
        'order' : 'market_cap_desc', # Order results by descending market cap.
        'per_page': 250, # Get 250 cryptocurrencies (max limit).
        'page': 1 #First page of results.
    }

    # Sending Requests
    response = requests.get(url, params=param)

    if response.status_code == 200:
        print('Connection Successfull! \nGetting the data...')
        
        # Storing The Response into Data
        data = response.json()
        
        # Creating df Dataframe
        df = pd.DataFrame(data)
        
        # Selecting Only Columns Needed - Data Cleaning
        df = df[[
            'id','current_price', 'market_cap', 'price_change_percentage_24h',
            'high_24h', 'low_24h','ath', 'atl',
        ]]
    
        #Creating New Columns
        today =  datetime.now().strftime('%d-%m-%Y %H:%M:%S')
        df['time_stamp'] = today
        
        # Getting Top 10 Negative
        top_negative_10 = df.nsmallest(10, 'price_change_percentage_24h')
        
        # Getting Top 10 Positive
        top_positive_10 = df.nlargest(10, 'price_change_percentage_24h')
        
        # Saving The Data
        file_name = f'crypto_data {today}.csv'
        df.to_csv(file_name, index=False)

        print(f"Data saved successfull as {file_name}!")
        
        # Call Email Function to Send The Reports
        
        subject = f"Top 10 crypto currency data to invest for {today}"
        body = f"""
        Good Morning!\n\n
        
        Your crypt reports is here!\n\n
        
        Top 10 crypto with highest price increase in last 24 hour!\n
        {top_positive_10}\n\n\n
        
        
        Top 10 crypto with highest price decrease in last 24 hour!\n
        {top_negative_10}\n\n\n
        
        Attached 250 plus crypto currency lattest reports\n
        
        
        Regards!\n
        See you tomorrow!\n
        Your crypto python application    
        """
        
        # Sending Email
        send_mail(subject, body, file_name)    
        
        print(f"Data saved successfull as {file_name}!")

        # This Get Executed Only If We Run This Function
if __name__ == '__main__':
    # Call The Function

    # Sheduling The Task at 8AM
    schedule.every().day.at('08:00').do(get_crypto_data)
    
    while True:
        schedule.run_pending()
        time.sleep(60)