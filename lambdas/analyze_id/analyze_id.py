"""
This function uses AWS TextExtract to analyze and extract data from identity documents, like:
- Passports
- Driver's Licenses
- Health Insurance Cards
- Social Security Cards
- Student ID Cards
- Work Permits and Residence Permits


Learn more about the API -> https://docs.aws.amazon.com/textract/latest/dg/analyzing-document-identity.html
Learn more about the response object -> https://docs.aws.amazon.com/textract/latest/dg/identitydocumentfields.html
"""


def lambda_handler(event: dict, context: dict) -> None:
    return True
