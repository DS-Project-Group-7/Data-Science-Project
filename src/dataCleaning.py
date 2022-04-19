import pandas as pd
import argparse

def main(dataFile):
    df = pd.read_excel(dataFile)

    fuseCategColumns(df,[9,13],"Support Type")
    fuseCategColumns(df, [138,139], "Support originality")
    fuseCategColumns(df, [140,141], "New support type")
    fuseCategColumns(df, [216,217], "Ground Layer to side or face edge")

    fuseOrdinalColumns(df,[23,24,25], "Auxiliary support Condition")
    fuseOrdinalColumns(df,[58,59,60, 61], "Media (Paint layer) Condition")
    fuseOrdinalColumns(df,[41,42,43], "Painting Support Condition")

    #The media ground layer quality has multiple values.
    #Ground layer to side or face edge also has a record with multiple values
    df.to_csv('../data/rawDataPlusCleanColumns.csv')
    print("done")

def fuseCategColumns(df,indexList, colName):
    """Fuse an array of columns in a dataframe that show diferent aspects of the same categorical variable
    df : pandas dataframe object
    indexList : list of the indexes of the columns we want to fuse
    colName: name of the fused column
    """

    #Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical or numerical value of the column
    for index in indexList:
        df.iloc[:,index]=df.iloc[:,index].fillna('')

    #Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    #Might want to add a verification part though
    df[colName] = df.iloc[:,indexList[0]]
    for index in indexList[1:]:
        df[colName]+= df.iloc[:,index]

def fuseOrdinalColumns(df,orderedIndexList, colName):
    """Fuse an array of columns in a dataframe that show diferent levels of the same categorical variable
    df : pandas dataframe object
    indexList : list of the indexes of the columns we want to fuse, from the lower level to the highest
    colName: name of the fused column
    """

    #Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical, ordinal or numerical value of the column
    for index in orderedIndexList:
        df.iloc[:,index]=df.iloc[:,index].fillna(0)

    #Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    #Might want to add a verification part though
    level=0
    df[colName] = level #set the default value to 0

    for index in orderedIndexList[1:]:
        level+=1
        df.loc[df.iloc[:,index]!=0, colName]=level

def parseArguments():
    parser = argparse.ArgumentParser()

    # Optional arguments
    parser.add_argument("-d", "--data", help="Csv data file path", type=str, default='../data/Behaviour of Canvas_CR_2022Export.xlsx')

    # Parse arguments
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    args = parseArguments()
    main(args.data)