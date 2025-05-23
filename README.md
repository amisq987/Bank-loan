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
- Source: [Bank Loan Dataset](financial_loan.csv)

# I. Data Cleaning:
- In our journey to understand the dynamics behind financial loan data, we begin by equipping ourselves with essential tools as well as setting a clean aesthetic to ensure our visualizations are both appealing and readable.
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
## 1. Loading dataset:
```python
df = pd.read_csv('/content/financial_loan.csv')
df.head(5)
```
<center>
      <img src="png/df.head5.png"/>
  </center>

```python
df.info()
```
<center>
      <img src="png/df.info.png"/>
  </center>
  
## 2. Checking null values:
```python
df.isnull().sum()
```
<center>
      <img src="png/df.isnull.png"/>
  </center>
  
- We uncover where information is missing. One such silence lies in the emp_title column.
```python
# Handle missing values in emp_title (employment title)
df['emp_title'].fillna('Not Provided', inplace=True)
```
## 3. Checking duplicated values:
```python
df.duplicated().sum()
```
<center>
      <img src="png/df.duplicated.png"/>
  </center>
  
## 4. Transform data:
- First let's check the 'object' columns. We see that there are some columns that can be transformed to date or numeric columns.
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
<center>
      <img src="png/object.nuinique.png"/>
  </center>
  
- Check how many unique values are in object columns. We check if binning is needed. Check all for any inconsistences or imbalances
```python
def value_counter(df):
    value_series = pd.DataFrame()
    for col in df.select_dtypes(["object"]).columns:
        print(df[col].value_counts(dropna = False))

value_counter(df)
```
<center>
      <img src="png/binning1.png"/>
  </center>

<center>
      <img src="png/binning2.png"/>
  </center>

<center>
      <img src="png/binning3.png"/>
  </center>

### 📝 Key observations
- sub_grade : is already groupped by grade
- home_ownership : The majority categories (mortgage and rent) dominate the data, while own and especially other are underrepresented. Such an imbalance can lead to biased models, where predictions are skewed toward the majority classes.
- purpose : here is huge imbalance, especialy on especialy on medical, car, small_business, vacation, moving, house, renewable_energy, wedding, educational. It should be grouped to simplify the purpose.
- addr_state : as well

```python
# Create a new column for loan purpose category (simplifying the purpose)
purpose_mapping = {
    'car': 'vehicle',
    'Debt consolidation': 'debt consolidation',
    'credit card': 'credit card',
    'home improvement': 'home improvement',
    'other': 'other',
    'major purchase': 'major purchase',
    'medical': 'medical',
    'small business': 'business',
    'vacation': 'personal',
    'moving': 'personal',
    'house': 'housing',
    'renewable energy': 'home improvement',
    'wedding': 'personal'
}
df['purpose_category'] = df['purpose'].map(lambda x: purpose_mapping.get(x, 'other'))
```
```python
print("\nData after cleaning:")
display(df.head())
```
<center>
      <img src="png/df.cleaned.png"/>
  </center>

# II. EDA:
## 1. Overview:
### **Numerical columns statistics**
```python
num_cols = ['annual_income', 'dti', 'installment', 'int_rate', 'loan_amount', 'total_acc', 'total_payment']
print("Numerical Columns Statistics:")
display(df[num_cols].describe())
```
<center>
      <img src="png/num.describe.png"/>
  </center>

### **Categorical columns statistics**
```python
cat_cols = ['application_type', 'grade', 'home_ownership', 'purpose', 'sub_grade', 'term', 'verification_status', 'loan_status']
print("\nCategorical Columns Value Counts:")
for col in cat_cols:
    print(f"\n{col}:")
    display(df[col].value_counts(normalize=True).head(10))
```
<center>
      <img src="png/cate.describe1.png"/>
  </center>

<center>
      <img src="png/cate.describe2.png"/>
  </center>

<center>
      <img src="png/cate.describe3.png"/>
  </center>
  
#### 📝 Mini conclusion
- The average loan amount is around $11,296 with a wide range from $500 to $35000,000
- Interest rates vary from 5.4% to 24.6%
- Most loans (73%) are for 36 months term
- The most common loan purpose is for Debt consolidation
- About 83% of loans are fully paid, while 14% are charged off
- Most applicants (48%) are renting their homes

## 2. Loan Status Analysis
### **Loan status distribution**
Our goal is to understand how loans typically end. The chart below shows the number of loans for each status, such as "Fully
Paid", "Charged Off", etc.
```python
plt.figure(figsize=(10, 6))
sns.countplot(data=df, x='loan_status', order=df['loan_status'].value_counts().index,palette='Set2')
plt.title('Distribution of Loan Status')
plt.xlabel('Loan Status')
plt.ylabel('Number of Loans')
plt.tight_layout()
plt.show()
```
<center>
      <img src="png/loanstatus.dis.png"/>
  </center>
  
- The majority of loans in the dataset are fully paid, indicating strong repayment behavior among borrowers. However, a significant portion has been charged off, reflecting a measurable level of credit risk.

### **Loan status by loan amount**
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
<center>
      <img src="png/status.vs.amount.png"/>
  </center>
  
- Current loans have the highest median and widest range of loan amounts, indicating that larger loans tend to remain active longer.
- Charged-off and fully paid loans have similar, lower medians, suggesting that smaller loans are more likely to reach a resolution.
- Defaults are not limited to high loan amounts—many charged-off loans are relatively small, pointing to other contributing risk factors beyond just loan size.
- There are notable outliers across all categories, especially for Fully Paid and Charged Off loans. These outliers could represent special cases like debt consolidation or high-risk lending—worth flagging for deeper investigation.

### **Default rate by grade**
📌 The **default rate** is the percentage of loans (or borrowers) that fail to meet their repayment obligations on time according to the agreed terms. 
```python
default_rate = df.groupby('grade')['loan_status'].apply(lambda x: (x == 'Charged Off').mean()).reset_index()
default_rate.rename(columns={'loan_status': 'default_rate'}, inplace=True)

plt.figure(figsize=(12, 6))
sns.barplot(data=default_rate,x='grade',y='default_rate', palette='coolwarm')
plt.title('Default Rate by Loan Grade')
plt.xlabel('Loan Grade')
plt.ylabel('Default Rate')
plt.ylim(0, 1) 
plt.tight_layout()
plt.show()
```
<center>
      <img src="png/defaultrate.grade.png"/>
  </center>

- Defaulted loans tend to have slightly higher loan amounts
- Lower grade loans (E, F, G) have significantly higher default rates (30-35%) compared to higher grades (A, B). This suggests the grading system is effective at identifying riskier loans.

## 3. Loan Characteristics Analysis
### **Loan issuance over time**
```python
# Extract year-month for monthly analysis
df['issue_month'] = df['issue_date'].dt.to_period('M').astype(str)

# Loan issuance over time (by month)
loans_by_month = df['issue_month'].value_counts().sort_index()

plt.figure(figsize=(12, 6))
loans_by_month.plot(kind='bar', color=sns.color_palette('Set3'))
plt.title('Monthly Loan Issuance')
plt.xlabel('Month')
plt.ylabel('Number of Loans')
plt.show()
```
<center>
      <img src="png/monthly.png"/>
  </center>

- In 2021, loan issuance steadily grew month after month. This steady rise likely reflects a recovering economy and growing consumer confidence after the pandemic's early impact. All in all, no clear seasonal pattern was seen.

### **Loan amount distribution**
This histogram shows the distribution of loan amounts, while the KDE curve spots any unusual spikes that might hint at specific lending trends or constraints.
```python
plt.figure(figsize=(12, 6))
sns.histplot(data=df, x='loan_amount', bins=30, kde=True,color='skyblue')
plt.title('Distribution of Loan Sizes')
plt.xlabel('Loan Amount ($)')
plt.ylabel('Frequency')
plt.show()
```
<center>
      <img src="png/size.dis.png"/>
  </center>
  
- Most loans are between $3,000 and $12,000, peaking around $5,000, while fewer high-value loans above $20,000, indicating limited demand or stricter approval.
- The curve (KDE) shows a right-skewed distribution—most people borrow smaller amounts, while only a few take on larger debts. This suggests that risk appetite or creditworthiness may limit access to higher loan amounts.

### **Interest rate by Loan grade**
```python
plt.figure(figsize=(12, 6))
sns.boxplot(data=df, x='grade', y='int_rate', order=['A', 'B', 'C', 'D', 'E', 'F', 'G'],palette='coolwarm')
plt.title('Loan Grade vs. Interest Rate')
plt.xlabel('Loan Grade')
plt.ylabel('Interest Rate')
plt.show()
```
<center>
      <img src="png/grade.vs.int.png"/>
  </center>
  
- This boxplot reveals how lenders adjust interest to offset risk: loan grade worsens from A to G, interest rates increase.
- Grade A loans have the lowest and tightest spread of rates, while grade G loans have the highest median interest rates and greater variability. Futhermore, grades C to E show more outliers and wider IQRs, indicating greater diversity in borrower profiles within these grades.

### **Loan purpose distribution**
```python
plt.figure(figsize=(12, 6))
df['purpose_category'].value_counts().plot(kind='bar',color=sns.color_palette('Set2'))
plt.title('Loan Purpose Distribution')
plt.xlabel('Purpose Category')
plt.ylabel('Number of Loans')
plt.xticks(rotation=45)
plt.show()
```
<center>
      <img src="png/purpose.dis.png"/>
  </center>

- Debt consolidation is the most common loan purpose by far. Credit card loans are the second most frequent, both indicating debt management focus.
- Categories like home improvement, major purchase, and personal loans are common but far less frequent. Indicates moderate use of loans for discretionary or planned expenses.

### Loan distribution by state

```python
# Count loans by state
loan_counts = df['address_state'].value_counts().reset_index()
loan_counts.columns = ['state', 'loan_count']

# Create a choropleth map
fig = px.choropleth(loan_counts,locations='state',
locationmode='USA-states',color='loan_count',
color_continuous_scale='Blues',scope='usa',
labels={'loan_count': 'Number of Loans'},
title='Loan Distribution by State')

fig.show()
```
<center>
      <img src="png/state.distribution.png"/>
  </center>
  
- California has the highest number of loans, followed by Florida and Texas - which also have a relatively high number of loans. Most other states don't have nearly as many. It seems like more loans happen in more populated states.

## 4. Borrower Characteristics Analysis
### **Annual income distribution**
Let’s start by examining borrowers’ earning power. We'll exclude extreme outliers above $200,000 to focus on the bulk of the population.
```python
# Annual income distribution
plt.figure(figsize=(12, 6))
sns.histplot(data=df, x='annual_income', bins=30, kde=True)
plt.title('Distribution of Annual Income')
plt.xlabel('Annual Income ($)')
plt.ylabel('Number of Borrowers')
plt.xlim(0, 200000)  # Remove extreme outliers for better visualization
plt.show()
```
<center>
      <img src="png/income.dis.png"/>
  </center>
  
- Most borrowers earn between $30,000 and $75,000 annually, suggesting the loan platform caters primarily to middle-income individuals.
- A significant drop-off in counts occurs after $75,000, indicating income distribution is right-skewed.

### **Home ownership distribution**
```python
plt.figure(figsize=(10, 6))
df['home_ownership'].value_counts().plot(kind='bar',color=sns.color_palette('Set2'))
plt.title('Home Ownership Distribution')
plt.xlabel('Home Ownership Status')
plt.ylabel('Number of Borrowers')
plt.show()
```
<center>
      <img src="png/home.dis.png"/>
  </center>
  
- Most people either rent or are still paying off a mortgage—very few actually own their home outright. That means most borrowers likely have ongoing monthly housing costs.
- There are barely any in the “other” or “none” categories, so we’re mostly looking at pretty typical housing situations.

### **Employment length distribution**
```python
plt.figure(figsize=(12, 6))
df['emp_length'].value_counts().plot(kind='bar',color=sns.color_palette('Set3'))
plt.title('Employment Length Distribution')
plt.xlabel('Employment Length')
plt.ylabel('Number of Borrowers')
plt.show()
```
<center>
      <img src="png/emplength.dis.png"/>
  </center>
  
- A big chunk of people in the dataset have been at their job for 10+ years—that’s a strong sign of stability. On the flip side, there's also a noticeable group with only 1 year of employment, which could signal newer workers or recent job changes.
- As the number of years increases from 2 to 9, the counts gradually taper off. It’s a mix, but overall, we see a healthy portion with long-term employment, which is a positive indicator for creditworthiness.

# DASHBOARDS

[Link to DASHBOARDS](https://public.tableau.com/shared/549H7PNY4?:display_count=n&:origin=viz_share_link)

## DASHBOARD 1: SUMMARY
In order to monitor and assess our bank's lending activities and performance, we need to create a comprehensive Bank Loan Report. This report aims to provide insights into key loan-related metrics and their changes over time. The report will help us make data-driven decisions, track our loan portfolio's health, and identify trends that can inform our lending strategies.
**Key Performance Indicators (KPIs)** Requirements:
- **Total Loan Applications**: We need to calculate the total number of loan applications received during a specified period. Additionally, it is essential to monitor the Month-to-Date (MTD) Loan Applications and track changes Month-over-Month (MoM).
- **Total Funded Amount**: Understanding the total amount of funds disbursed as loans is crucial. We also want to keep an eye on the MTD Total Funded Amount and analyse the Month-over-Month (MoM) changes in this metric.
- **Total Amount Received**: Tracking the total amount received from borrowers is essential for assessing the bank's cash flow and loan repayment. We should analyse the Month-to-Date (MTD) Total Amount Received and observe the Month-over-Month (MoM) changes.
- **Average Interest Rate**: Calculating the average interest rate across all loans, MTD, and monitoring the Month-over-Month (MoM) variations in interest rates will provide insights into our lending portfolio's overall cost.
- **Average Debt-to-Income Ratio (DTI)**: Evaluating the average DTI for our borrowers helps us gauge their financial health. We need to compute the average DTI for all loans, MTD, and track Month-over-Month (MoM) fluctuations.

<center>
      <img src="png/SUMMARY.png"/>
  </center>

## DASHBOARD 2: OVERVIEW
In our Bank Loan Report project, we aim to visually represent critical loan-related metrics and trends using a variety of chart types. These charts will provide a clear and insightful view of our lending operations, facilitating data-driven decision-making and enabling us to gain valuable insights into various loan parameters.

**1. Monthly Trends by Issue Date (Line Chart):**
- Chart Type: Line Chart
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- X-Axis: Month (based on 'Issue Date')
- Y-Axis: Metrics' Values
- Objective: This line chart will showcase how 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received' vary over time, allowing us to identify seasonality and long-term trends in lending activities.

**2. Regional Analysis by State (Filled Map):**
- Chart Type: Filled Map
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- Geographic Regions: States
- Objective: This filled map will visually represent lending metrics categorized by state, enabling us to identify regions with significant lending activity and assess regional disparities.

**3. Loan Term Analysis (Donut Chart):**
- Chart Type: Donut Chart
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- Segments: Loan Terms (e.g., 36 months, 60 months)
- Objective: This donut chart will depict loan statistics based on different loan terms, allowing us to understand the distribution of loans across various term lengths.

**4. Employee Length Analysis (Bar Chart):**
- Chart Type: Bar Chart
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- X-Axis: Employee Length Categories (e.g., 1 year, 5 years, 10+ years)
- Y-Axis: Metrics' Values
- Objective: This bar chart will illustrate how lending metrics are distributed among borrowers with different employment lengths, helping us assess the impact of employment history on loan applications.
  
**5. Loan Purpose Breakdown (Bar Chart):**
- Chart Type: Bar Chart
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- X-Axis: Loan Purpose Categories (e.g., debt consolidation, credit card refinancing)
- Y-Axis: Metrics' Values
- Objective: This bar chart will provide a visual breakdown of loan metrics based on the stated purposes of loans, aiding in the understanding of the primary reasons borrowers seek financing.
  
**6. Home Ownership Analysis (Tree Map):**
- Chart Type: Tree Map
- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received'
- Hierarchy: Home Ownership Categories (e.g., own, rent, mortgage)
- Objective: This tree map will display loan metrics categorized by different home ownership statuses, allowing for a hierarchical view of how home ownership impacts loan applications and disbursements.

These diverse chart types will enhance our ability to visualize and communicate loan-related insights effectively, supporting data-driven decisions and strategic planning within our lending operations.

<center>
      <img src="png/OVERVIEW.png"/>
  </center>

## DASHBOARD 3: DETAILS
In our Bank Loan Report project, we recognize the need for a comprehensive 'Details Dashboard' that provides a consolidated view of all the essential information within our loan data. This Details Dashboard aims to offer a holistic snapshot of key loan-related metrics and data points, enabling users to access critical information efficiently.
*Objective*: The primary objective of the Details Dashboard is to provide a comprehensive and user-friendly interface for accessing vital loan data. It will serve as a one-stop solution for users seeking detailed insights into our loan portfolio, borrower profiles, and loan performance.

<center>
      <img src="png/DETAILS.png"/>
  </center>





















