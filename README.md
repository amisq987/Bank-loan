# Loan Application and Management

## 📌 Project objective
In order to monitor and assess our bank's lending activities and performance, we need to create a comprehensive Loan Application and Management Report. This report aims to provide insights into key loan-related metrics and their changes over time. The report will help us make data-driven decisions, track our loan portfolio's health, and identify trends that can inform our lending strategies.
## 🔍 Understanding the business process
When the company receives a loan application, the company has to make a decision for loan approval based on the applicant’s profile. Here’s an overview of the business process:
1. **Loan Application Submission**
The customer submits a loan application through online, in-person, or alternative channels.
2. **Application & Identity Review**
The lender reviews the application, verifies the applicant’s identity, and collects required documentation (ID, income proof, credit consent, etc.).
3. **Creditworthiness & Risk Evaluation**
- **Credit Check**: Reviewing credit reports and scores
- **Income Verification**: Validating income through pay stubs or tax returns
- **Debt-to-Income (DTI) Analysis**: Calculating DTI to assess repayment capacity
- **Employment Verification**: Confirming current job and employment stability
- **Collateral Evaluation** (if applicable): Assessing pledged assets for secured loans
- **Overall Risk Assessment**: Evaluating total borrower risk profile
4. **Loan Decision & Agreement**
Based on the evaluation, the loan is either approved or denied. If approved, the lender sets the terms (amount, interest rate, tenure) and provides a loan agreement for the borrower to review and sign.
5. **Disbursement & Loan Management**
After signing, the lender disburses the funds. The borrower begins repayment as per the agreed schedule. The lender monitors repayment behavior, manages delinquencies if any, and assesses the loan’s ongoing performance.
## 🛠 Technologies used
- Python (Pandas, NumPy, Matplotlib, Seaborn) using Google Colab: Data overview, Data cleaning (ensure the integrity of dataset) and EDA.
- SQL using MySQL Workbench: Double check the KPIs in the dashboards.
- Tableu: Visualisations.
## 📂 Dataset
- Source: [Bank Loan Dateset]()

# Data Loading
1. Reading file:
```python
import numpy as np
import pandas as pd
import os
import seaborn as sns
from matplotlib import pyplot as plt
```
```python
df = pd.read_csv('/content/financial_loan.csv')
df.head(2)
```
```python
df.info()
```
```python
df.isnull().sum()
```
```python
df.duplicated().sum()
```
```python
df['issue_date'] = pd.to_datetime(df['issue_date'], format="%d-%m-%Y")
df['last_credit_pull_date'] = pd.to_datetime(df['last_credit_pull_date'], format="%d-%m-%Y")
df['last_payment_date'] = pd.to_datetime(df['last_payment_date'],format="%d-%m-%Y")
df['next_payment_date'] = pd.to_datetime(df['next_payment_date'],format="%d-%m-%Y")
```
2. EDA:




