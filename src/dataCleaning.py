from calendar import c
import numpy as np
import pandas as pd
import argparse

from pyparsing import col

# Definition of Dictionaries that link a wanted new feature to the index of the the ones they are computed from
# Eg. New feature "Support Type" from CategoricalColumnsDict will refer to columns 9 and 13 of the originial excel data file.
BooleanColumnsDict = {
    "Original suppport": 45,
    "planar (auxiliary support)": 56,
    "warped (auxiliary support)": 57,
    "mould (auxiliary support)": 58,
    "surface dirt (auxiliary support)": 59,
    "staining (auxiliary support)": 60,
    "insect damage (auxiliary support)": 61,
    "accretions (auxiliary support)": 62,
    "indentations (auxiliary support)": 63,
    "prev. treatment (auxiliary support)": 50,
    "joins unstable (auxiliary support)": 51,
    "joins split (auxiliary support)": 52,
    "joins not flat (auxiliary support)": 53,
    "Adhered well to support": 80,
    "cracking (media)": 81,
    "cleavage (media)": 82,
    "flaking (media)": 83,
    "losses (media)": 84,
    "abrasions (media)": 85,
    "surface dirt (media)": 86,
    "accretions (media)": 87,
    "discolouration (media)": 88,
    "overpainting (media)": 89,
    "Commercial ground": 120,
    "Artist applied ground": 121,
    "size layer visible": 122,
    "thickly applied": 123,
    "thinly applied": 124,
    "coloured ground": 125,
    "id sulphate": 126,
    "uniform application": 127,
    "id carbonate": 128,
    "ground proprietary paint?": 131,
    "prev. treatment (ground)": 136,
    "Appears Plastic": 108,
    "Appears Elastic": 109,
    "dry cured": 110,
    "infilling": 111,
    "planar (painting support)": 136,
    "corner distortions painting support": 137,
    "warped (painting support)": 138,
    "indentations (painting support)": 139,
    "good tension (painting support)": 140,
    "holes (painting support)": 141,
    "loose (painting support)": 142,
    "tears (painting support)": 143,
    "taut (painting support)": 144,
    "surface dirt (painting support)": 145,
    "mould (painting support)": 146,
    "staining (painting support)": 147,
    "overall distortions (painting support)": 148,
    "insect damage (painting support)": 149,
    "bottom distortions (painting support)": 150,
    "rust stains on support (painting support)": 151,
    "top distortions (painting support)": 152,
    "deformation around tacks staples (painting support)": 153,
    "tears around tacks staples (painting support)": 154,
    "loss of tacks insecure support (painting support)": 155,
}

CategoricalColumnsDict = {
    "Accession number": [0],
    "Title": [12],
    "Date": [13],
    "Country": [14],
    "Collection": [15],
    "Support Type": [46, 47, 48, 49],
    "To reverse/face edge": [129, 130],
    "media type 1": [112],
    "media type 2": [113],
    "media type 3": [114],
    "Wood type hardness": [76],
    "Wood type": [77],
    "Wood type Country": [78],
    "Wood type locality": [79],
    "Commentary Auxiliary support": [64],
    "Sight": [7],
}

OrdinalColumnsDict = {
    "Auxiliary support Condition": [65, 66, 67, 68],
    "Media Condition": [90, 91, 92, 93],
    "Painting support condition": [132, 133, 134, 135],
}


def main(dataFile):
    cleanDataDf = pd.DataFrame()
    originalDataDf = pd.read_excel(dataFile)

    for feature in CategoricalColumnsDict:
        cleanDataDf[feature] = fuseCategColumns(
            originalDataDf, CategoricalColumnsDict[feature], feature
        )
        if feature == "Collection":
            cleanDataDf[feature] = cleanDataDf[feature].replace(
                to_replace=".*([sS]ingapore).*",
                value="National Heritage Board",
                regex=True,
            )
        elif feature == "Sight":
            cleanDataDf["Area"] = computeArea(cleanDataDf, feature)

    for feature in OrdinalColumnsDict:
        cleanDataDf[feature] = fuseOrdinalColumns(
            originalDataDf, OrdinalColumnsDict[feature], feature
        )

    for feature in BooleanColumnsDict:
        cleanDataDf[feature] = makeBoolCol(originalDataDf, BooleanColumnsDict[feature])

    # The media ground layer quality has multiple values.
    # Ground layer to side or face edge also has a record with multiple values
    cleanDataDf.to_csv("../data/cleanData.csv")
    print("done")


def makeBoolCol(originalDf, index):
    """ Copy a text feature from a column.
    originalDf : pandas dataframe of original data
    cleanDf : pandas dataframe of cleansed columns
    index : index of the column
    colName: name of the fused column
    """
    return (~originalDf.iloc[:, index].isnull()).astype(int)


def fuseCategColumns(originalDf, indexList, colName):
    """Fuse an array of columns in a dataframe that show diferent aspects of the same categorical variable
    originalDf : pandas dataframe of original data
    indexList : list of the indexes of the columns we want to fuse
    colName: name of the fused column
    """
    newColumn = pd.DataFrame(columns=[colName])

    # Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical or numerical value of the column
    for index in indexList:
        originalDf.iloc[:, index] = originalDf.iloc[:, index].fillna("")

    # Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    # Might want to add a verification part though
    newColumn[colName] = originalDf.iloc[:, indexList[0]]
    for index in indexList[1:]:
        newColumn[colName] += originalDf.iloc[:, index]
    return newColumn[colName]


def fuseOrdinalColumns(originalDf, orderedIndexList, colName):
    """Fuse an array of columns in a dataframe that show diferent levels of the same categorical variable
    originalDf : pandas dataframe of original data
    indexList : list of the indexes of the columns we want to fuse, from the lower level to the highest
    colName: name of the fused column
    """

    newColumn = pd.DataFrame(columns=[colName])
    # Replace Nans with an empty string -> might want a method that parses the df and does an appropriate filling according to the categorical, ordinal or numerical value of the column
    for index in orderedIndexList:
        originalDf.iloc[:, index] = originalDf.iloc[:, index].fillna(int(0))

    # Since columns should be aligned (when a columns is not empty, all the others shuld be), we can just add them up
    # Might want to add a verification part though
    level = 0
    newColumn[colName] = originalDf.iloc[:, orderedIndexList[0]]
    newColumn[colName] = 0  # set the default value to 0

    for index in orderedIndexList[1:]:
        level += 1
        researchInOrigin = (originalDf.iloc[:, index] != 0) & (
            originalDf.iloc[:, index] != "n/a"
        )
        newColumn.loc[researchInOrigin & (newColumn[colName] != 0), colName] = np.floor(
            (
                newColumn.loc[researchInOrigin & (newColumn[colName] != 0), colName]
                + level
            )
            / 2
        )
        newColumn.loc[researchInOrigin, colName] = level
        newColumn.loc[originalDf.iloc[:, index] == "n/a", colName] = np.nan

    return newColumn[colName]


def computeArea(oldDataframe, feature):
    """
    Extract the length and the width of all paintings and calculate their areas.
    """
    lengthWidthDf = oldDataframe[feature].str.extract(
        r"(\d+\.*\d+)(?:\s*[xX]\s*)(\d+\.*\d+)", expand=False
    )
    lenWidDfNan = lengthWidthDf.fillna(0).astype(
        float
    )  # transforms nans into 0s (nans are rows where there is a missing value for 'sight')
    return lenWidDfNan.iloc[:, 0] * lenWidDfNan.iloc[:, 1]


def parseArguments():
    parser = argparse.ArgumentParser()

    # Optional arguments
    parser.add_argument(
        "-d",
        "--data",
        help="Csv data file path",
        type=str,
        default="../Cleaning_data/ManuallyCleanedData.xlsx",
    )

    # Parse arguments
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = parseArguments()
    main(args.data)
