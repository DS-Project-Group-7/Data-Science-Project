from calendar import c
import pandas as pd
import argparse

# Definition of Dictionaries that link a wanted new feature to the index of the the ones they are computed from
# Eg. New feature "Support Type" from CategoricalColumnsDict will refer to columns 9 and 13 of the originial excel data file.
BooleanColumnsDict={
"Ground Layer to side edge": 216,
"Ground Layer to face edge": 217
}

CategoricalColumnsDict={
"Support Type": [9,13],
"Support originality": [138,139],
"New support type": [140,141],
}

OrdinalColumnsDict={
"Auxiliary support Condition":[23,24,25],
"Media (Paint layer) Condition": [58,59,60, 61],
"Painting Support Condition":[41,42,43]
}


def main(dataFile):
    cleanDataDf = pd.DataFrame()
    originalDataDf = pd.read_excel(dataFile)

    for feature in CategoricalColumnsDict:
        fuseCategColumns(originalDataDf, cleanDataDf, CategoricalColumnsDict[feature], feature)

    for feature in OrdinalColumnsDict:
        fuseOrdinalColumns(originalDataDf,cleanDataDf, OrdinalColumnsDict[feature], feature)

    for feature in BooleanColumnsDict:
        makeBoolCol(originalDataDf, cleanDataDf, BooleanColumnsDict[feature], feature)

    #The media ground layer quality has multiple values.
    #Ground layer to side or face edge also has a record with multiple values
    cleanDataDf.to_csv('../data/cleanData.csv')
    print("done")


def makeBoolCol(originalDf,cleanDf, index, colName):
    """ Create a proper boolean feature from a column which values would either be present or absent
    originalDf : pandas dataframe of original data
    cleanDf : pandas dataframe of cleansed columns
    index : index of the column
    colName: name of the fused column
    """
    cleanDf[colName] = (~originalDf.iloc[:,index].isnull()).astype(int)
    

def fuseCategColumns(originalDf,cleanDf ,indexList, colName):
    """Fuse an array of columns in a dataframe that show diferent aspects of the same categorical variable
    originalDf : pandas dataframe of original data
    cleanDf : pandas dataframe of cleansed columns
    indexList : list of the indexes of the columns we want to fuse
    colName: name of the fused column
    """

    #Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical or numerical value of the column
    for index in indexList:
        originalDf.iloc[:,index]=originalDf.iloc[:,index].fillna('')

    #Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    #Might want to add a verification part though
    cleanDf[colName] = originalDf.iloc[:,indexList[0]]
    for index in indexList[1:]:
        cleanDf[colName]+= originalDf.iloc[:,index]

def fuseOrdinalColumns(originalDf,cleanDf,orderedIndexList, colName):
    """Fuse an array of columns in a dataframe that show diferent levels of the same categorical variable
    originalDf : pandas dataframe of original data
    cleanDf : pandas dataframe of cleansed columns
    indexList : list of the indexes of the columns we want to fuse, from the lower level to the highest
    colName: name of the fused column
    """

    #Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical, ordinal or numerical value of the column
    for index in orderedIndexList:
        originalDf.iloc[:,index]=originalDf.iloc[:,index].fillna(0)

    #Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    #Might want to add a verification part though
    level=0
    cleanDf[colName] = level #set the default value to 0

    for index in orderedIndexList[1:]:
        level+=1
        cleanDf.loc[originalDf.iloc[:,index]!=0, colName]=level

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