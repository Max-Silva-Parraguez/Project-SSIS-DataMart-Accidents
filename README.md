# CREATING A TRAFFIC ACCIDENT DATAMART IN THE USA (2016 - 2023)

## I. UNDERSTANDING THE DATA AND THE PROJECT

The data was obtained from car accident records throughout the USA, covering 49 states. The data covers from February 2016 to March 2023. It is in a `.csv` file with approximately 7.7 million accident records.

This project consists of processing the `.csv` data using an ETL (Extraction, Transformation and Loading) process to store it in a **DataMart**, organized in a **star** schema.

### Data source

Data was obtained from Kaggle:
[https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents](https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents)

The process that was carried out was:

![Image](https://github.com/user-attachments/assets/ac8737b2-56ce-446d-af63-44520bf6633d)
---

## II. FIRST: FROM CSV TO LOAD_ACCIDENTS

The .csv in question contains 46 columns, each of which is detailed below:

![Image](https://github.com/user-attachments/assets/a1213a2f-096b-4cf5-a784-f57451d421b0)
Since the `.csv` file is **3GB** in size and contains **7.7 million records**, it is ideal to move it to a load table in **SQL Server** before inserting it into the final database. This allows the data to be handled in a more efficient and controlled manner.

### Creating the `LOAD_ACCIDENTS` database and `L_ACCIDENTS` table

1. **Connect SSIS** to the `.csv` file.
2. **Transform the data** as needed.
3. **Load the information** into the `LOAD_ACCIDENTS` database.

![Image](https://github.com/user-attachments/assets/4c4ea1ed-3c26-4b07-90e8-3fe89ad51832)
---

## III. SECOND: FROM LOAD_ACCIDENTS to STAGING_ACCIDENTS (Data Cleansing)

In this stage, duplicates are eliminated, data is normalized, and errors are corrected using the following processes in SSIS:

- **Sort**
- **Data Conversion**
- **Derive Column**
- **Lookup**

After cleaning, the data is stored in the `STAGING_ACCIDENTS` database, within the `S_ACCIDENTS` table.

![Image](https://github.com/user-attachments/assets/da7156a7-2c88-4969-9c0b-4bbda3868654)

---

## IV. THIRD: FROM STAGING_ACCIDENTS TO DATAMART_ACCIDENTS

The **Datamart** is organized under a **star schema**. The `DATAMART_ACCIDENTS` database is created along with its dimensions and fact table. In addition, intermediate tables are used in `STAGING_ACCIDENTS` to store modified records.

![Image](https://github.com/user-attachments/assets/e6aba11b-77c3-4018-af29-fe526bf4d5d8)

### Population of dimensions:

1. **Location dimension**: Location of the accident.
2. **Weather dimension**: Weather conditions at the time of the accident.
3. **Road Features dimension**: Road characteristics.
4. **Description Accidents dimension**: Reason for the accident.
5. **Time dimension**: Date and time of the accident.

### Population of the Facts Table:

Contains the foreign keys of the dimensions and the aggregated data of the accidents.

![Image](https://github.com/user-attachments/assets/bf2eee7d-cfd5-4ba4-8c27-36ef711b5986)

---

## MAIN PROJECT AND EMAIL SENDING

Finally, a **MAIN-MASTER** project is created in SSIS that:

1. **Cleans** the tables to ensure clean data.
2. **Executes** the loading of each dimension and the fact table.
3. **Sends a notification email** at the end of the process.

The email was sent using **Script Task** in SSIS. For a production environment, it is recommended to use the **Send Mail Task Component**, configuring an appropriate mail server.

![Image](https://github.com/user-attachments/assets/807521ac-1d72-42da-a31b-5c201498112f)

---

## Final Project Execution

- When executing the project, it was validated that the entire process was completed correctly.
- An email was received confirming the successful completion of the ETL.

![Image](https://github.com/user-attachments/assets/bcd54898-1da0-466e-b096-73cd97b7a509)

---

### 📌 Notes:
The complete and detailed project process can be found in the PDF: SSIS - DataMart Accidents EEUU.pdf

