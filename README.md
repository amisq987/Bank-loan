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
- Python (Pandas, NumPy, Matplotlib, Seaborn) using Google Colab: Data cleaning (ensure the integrity of dataset) and EDA.
- SQL using MySQL Workbench: Double check the KPIs in the dashboards.
- Tableu: Visualisations.
## 📂 Dataset
- Source: [Bank Loan Dateset]()

# I. Data Cleaning:
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

# Set style for visualizations
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)
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
# Handle missing values in emp_title (employment title)
df['emp_title'].fillna('Not Provided', inplace=True)
```
```python
df.duplicated().sum()
```
First let's check the 'object' columns. We see that there are some columns that can be transformed to date or numeric columns.
```python
# Remove leading/trailing whitespaces from objects
df = df.apply(lambda x: x.str.strip() if x.dtype == "object" else x)

# Convert date columns to datetime
date_cols = ['issue_date', 'last_credit_pull_date', 'last_payment_date', 'next_payment_date']
for col in date_cols:
    df[col] = pd.to_datetime(df[col], format='%d-%m-%Y', errors='coerce')

# Clean interest rate (remove % and convert to decimal)
df['int_rate'] = df['int_rate'].astype(str).str.replace('%', '').astype(float) / 100

# Convert loan_status to categorical
df['loan_status'] = df['loan_status'].astype('category')

# One-hot encoding term column
df['term_36_months'] = np.where(df['term'] == '36 months', 1, 0)

# Simplification emp_length column
df['emp_length'] = pd.to_numeric(df['emp_length'].str.replace('<', '', regex=False).str[:2].str.strip(), errors='coerce')
```
```python
def get_sorted_unique_counts(df):
    # Select columns with categorical data
    object_cols = df.select_dtypes(include=['object', 'category']).columns
    
    # Get the number of unique entries in each categorical column
    object_nunique = {col: df[col].nunique() for col in object_cols}
    
    # Convert to DataFrame and sort by unique counts
    unique_counts = pd.DataFrame(list(object_nunique.items()), columns=['Column', 'Unique Count'])
    unique_counts = unique_counts.sort_values(by='Unique Count').reset_index(drop=True)
    
    return unique_counts

get_sorted_unique_counts(df)
```
Check how many unique values are in object columns. We check if binning is needed. Check all for any inconsistences or imbalances
```python
def value_counter(df):
    value_series = pd.DataFrame()
    for col in df.select_dtypes(["object"]).columns:
        print(df[col].value_counts(dropna = False))

value_counter(df)
```
### 📝 Key observations
- sub_grade : is already groupped by grade
- home_ownership : The majority categories (mortgage and rent) dominate the data, while own and especially other are underrepresented. Such an imbalance can lead to biased models, where predictions are skewed toward the majority classes.
- purpose : here is huge imbalance, especialy on especialy on medical, car, small_business, vacation, moving, house, renewable_energy, wedding, educational. It should be grouped to simplify the purpose.
- addr_state : as well

```python
# Create a new column for loan purpose category (simplifying the purpose)
purpose_mapping = {
    'car': 'vehicle',
    'debt_consolidation': 'debt_consolidation',
    'credit_card': 'credit_card',
    'home_improvement': 'home_improvement',
    'other': 'other',
    'major_purchase': 'major_purchase',
    'medical': 'medical',
    'small_business': 'business',
    'vacation': 'personal',
    'moving': 'personal',
    'house': 'housing',
    'renewable_energy': 'home_improvement',
    'wedding': 'personal'
}
df['purpose_category'] = df['purpose'].map(lambda x: purpose_mapping.get(x, 'other'))
```
```python
print("\nData after cleaning:")
display(df.head())
```
# II. EDA:
## 1. Overview:
Numerical columns statistics
```python
num_cols = ['annual_income', 'dti', 'installment', 'int_rate', 'loan_amount', 'total_acc', 'total_payment']
print("Numerical Columns Statistics:")
display(df[num_cols].describe())
```
Categorical columns statistics
```python
cat_cols = ['application_type', 'grade', 'home_ownership', 'purpose', 'sub_grade', 'term', 'verification_status', 'loan_status']
print("\nCategorical Columns Value Counts:")
for col in cat_cols:
    print(f"\n{col}:")
    display(df[col].value_counts(normalize=True).head(10))
```
### 📝 Mini conclusion
- The average loan amount is around $11,296 with a wide range from $500 to $35000,000
- Interest rates vary from 5.4% to 24.6%
- Most loans (73%) are for 36 months term
- The most common loan purpose is for Debt consolidation
- About 83% of loans are fully paid, while 14% are charged off
- Most applicants (48%) are renting their homes

## 2. Loan Status Analysis
- Loan status distribution
Our first goal is to understand how loans typically end. The chart below shows the number of loans for each status, such as "Fully
Paid", "Charged Off", etc.
```python
plt.figure(figsize=(10, 6))
sns.countplot(data=df, x='loan_status', order=df['loan_status'].value_counts().index,palette='Set2')
plt.title('Distribution of Loan Status')
plt.xlabel('Loan Status')
plt.ylabel('Count')
plt.tight_layout()
plt.show()
```
The majority of loans in the dataset are fully paid, indicating strong repayment behavior among borrowers. However, a significant portion has been charged off, reflecting a measurable level of credit risk.

- Loan status by loan amount
Next, let's explore whether larger loan amounts are more likely to default. The boxplot below shows the distribution of loan amounts for each loan status.
```python
plt.figure(figsize=(12, 6))
sns.boxplot(data=df, x='loan_status', y='loan_amount',palette='Set2')
plt.title('Loan Amount by Loan Status')
plt.xlabel('Loan Status')
plt.ylabel('Loan Amount ($)')
plt.tight_layout()
plt.show()
```
- Current loans have the highest median and widest range of loan amounts, indicating that larger loans tend to remain active longer.
- Charged-off and fully paid loans have similar, lower medians, suggesting that smaller loans are more likely to reach a resolution.
- Defaults are not limited to high loan amounts—many charged-off loans are relatively small, pointing to other contributing risk factors beyond just loan size.
- There are notable outliers across all categories, especially for Fully Paid and Charged Off loans. These outliers could represent special cases like debt consolidation or high-risk lending—worth flagging for deeper investigation.

## 3. Loan Characteristics Analysis

- Default rate by grade
One of the most critical risk indicators is the "grade" — the credit rating assigned to the loan. The following chart shows the default rate (i.e., Charged Off) for each grade from A (lowest risk) to G (highest risk).
```python
default_rate = df.groupby('grade')['loan_status'].apply(lambda x: (x == 'Charged Off').mean()).reset_index()
plt.figure(figsize=(12, 6))
sns.barplot(data=default_rate, x='grade', y='loan_status',palette='coolwarm')
plt.title('Default Rate by Loan Grade')
plt.xlabel('Loan Grade')
plt.ylabel('Default Rate')
plt.ylim(0, 1)
plt.tight_layout()
plt.show()
```


