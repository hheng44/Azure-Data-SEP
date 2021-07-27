#1th
import pandas as pd
# data = pd.read_csv(r"C:\Users\15713\Documents\pythom-homework\people\people_1.txt", sep='\t',header=0)
# data2 = pd.read_csv(r"C:\Users\15713\Documents\pythom-homework\people\people_1.txt", sep='\t',header=0)
# data = pd.concat([data,data2])


# # print(data.iloc[0,0])
# print(data.shape)
# print(data.head())

# data['FirstName'] = [firstname.lower() for firstname in data['FirstName'].values.tolist()]
# print(data['FirstName'][0])

# data['LastName'] = [lastname.lower() for lastname in data['LastName'].values.tolist()]
# print(data['LastName'][0])

# data['Email'] = [email.lower() for email in data['Email'].values.tolist()]
# print(data['Email'][0])

# data['Phone'] = [phone.replace('-', '') for phone in data['Phone'].values.tolist()]
# print(data['Phone'][0])

# data['Address'] = [address.replace('No.', '') for address in data['Address'].values.tolist()]
# data['Address'] = [address.replace('#', '') for address in data['Address'].values.tolist()]
# data['Address'] = [address.lower() for address in data['Address'].values.tolist()]
# print(data['Address'][0])

# data.drop_duplicates(keep='first', inplace=True)
# print(data.shape)

# data.to_csv(r"c:\Users\15713\Documents\pythom-homework\non_duplicate.csv")

#2th
import json
movie = pd.read_json(r"C:\Users\15713\Documents\pythom-homework\movie.json")

count = 0
j=0
for i in range(movie.shape[0]//8, movie.shape[0], movie.shape[0]//8):
    path = r"C:\Users\15713\Documents\vsworkproject\json"+ str(count) +".json"
    movie.iloc[j:i,:].to_json(path)
    count += 1
    j = i + 1

