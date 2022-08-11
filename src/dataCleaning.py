from calendar import c
import numpy as np
import pandas as pd
import argparse

from pyparsing import col

# Definition of Dictionaries that link a wanted new feature to the index of the the ones they are computed from
# Eg. New feature "Support Type" from CategoricalColumnsDict will refer to columns 9 and 13 of the originial excel data file.
BooleanColumnsDict = {
    "original_suppport": 45,
    "planar_auxiliary_support": 56,
    "warped_auxiliary_support": 57,
    "mould_auxiliary_support": 58,
    "surface_dirt_auxiliary_support": 59,
    "staining_auxiliary_support": 60,
    "insect_damage_auxiliary_support": 61,
    "accretions_auxiliary_support": 62,
    "indentations_auxiliary_support": 63,
    "prev_treatment_auxiliary_support": 50,
    "joins_unstable_auxiliary_support": 51,
    "joins_split_auxiliary_support": 52,
    "joins_not_flat_auxiliary_support": 53,
    "adhered_well_to_support": 80,
    "cracking_media": 81,
    "cleavage_media": 82,
    "flaking_media": 83,
    "losses_media": 84,
    "abrasions_media": 85,
    "surface_dirt_media": 86,
    "accretions_media": 87,
    "discolouration_media": 88,
    "overpainting_media": 89,
    "commercial_ground": 120,
    "artist_applied_ground": 121,
    "size_layer_visible": 122,
    "thickly_applied": 123,
    "thinly_applied": 124,
    "coloured_ground": 125,
    "id_sulphate": 126,
    "uniform_application": 127,
    "id_carbonate": 128,
    "ground_proprietary_paint": 131,
    "prev_treatment_ground": 136,
    "appears_plastic": 108,
    "appears_elastic": 109,
    "dry_cured": 110,
    "infilling": 111,
    "planar_painting_support": 136,
    "corner_distortions_painting_support": 137,
    "warped_painting_support": 138,
    "indentations_painting_support": 139,
    "good_tension_painting_support": 140,
    "holes_painting_support": 141,
    "loose_painting_support": 142,
    "tears_painting_support": 143,
    "taut_painting_support": 144,
    "surface_dirt_painting_support": 145,
    "mould_painting_support": 146,
    "staining_painting_support": 147,
    "overall_distortions_painting_support": 148,
    "insect_damage_painting_support": 149,
    "bottom_distortions_painting_support": 150,
    "rust_stains_on_support_painting_support": 151,
    "top_distortions_painting_support": 152,
    "deformation_around_tacks_staples_painting_support": 153,
    "tears_around_tacks_staples_painting_support": 154,
    "loss_of_tacks_insecure_support_painting_support": 155,
}

CategoricalColumnsDict = {
    "accession_number": [0],
    "title": [12],
    "date": [13],
    "country": [14],
    "collection": [15],
    "support_type": [46, 47, 48, 49],
    "canvas_wrapping": [129, 130],
    "media_type_1": [112],
    "media_type_2": [113],
    "media_type_3": [114],
    "wood_type_hardness": [76],
    "wood_type": [77],
    "wood_type_country": [78],
    "wood_type_locality": [79],
    "commentary_auxiliary_support": [64],
    "sight": [7],
}

OrdinalColumnsDict = {
    "auxiliary_support_condition": [65, 66, 67, 68],
    "media_condition": [90, 91, 92, 93],
    "painting_support_condition": [132, 133, 134, 135],
}


def main(dataFile):
    cleanDataDf = pd.DataFrame()
    originalDataDf = pd.read_excel(dataFile)

    for feature in CategoricalColumnsDict:
        cleanDataDf[feature] = fuseCategColumns(
            originalDataDf, CategoricalColumnsDict[feature], feature
        )
        if feature == "collection":
            cleanDataDf[feature] = cleanDataDf[feature].replace(
                to_replace=".*([sS]ingapore).*",
                value="National Heritage Board",
                regex=True,
            )
        elif feature == "sight":
            (
                cleanDataDf["length"],
                cleanDataDf["width"],
                cleanDataDf["area"],
            ) = computeLenWidthAndArea(cleanDataDf, feature)

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


def computeLenWidthAndArea(oldDataframe, feature):
    """
    Extract the length and the width of all paintings and calculate their areas.
    """
    lengthWidthDf = oldDataframe[feature].str.extract(
        r"(\d+\.*\d+)(?:\s*[xX]\s*)(\d+\.*\d+)", expand=False
    )
    lenWidDfNan = lengthWidthDf.fillna(0).astype(
        float
    )  # transforms nans into 0s (nans are rows where there is a missing value for 'sight')
    return (
        lenWidDfNan.iloc[:, 0],
        lenWidDfNan.iloc[:, 1],
        lenWidDfNan.iloc[:, 0] * lenWidDfNan.iloc[:, 1],
    )


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
