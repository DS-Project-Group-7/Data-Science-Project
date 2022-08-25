from calendar import c
from multiprocessing.sharedctypes import Value
import numpy as np
import pandas as pd
import argparse
import math

from pyparsing import col
import regex

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
    "size_layer_visible": 122,
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
    "striped_frame": 164,
    "carved_frame": 165,
    "gesso_moldings_on_frame": 166,
    "painted_or_stained_frame": 167,
    "gilded_frame": 168,
    "glass_frame": 173,
    "perspex_frame": 174,
    "unable_to_examine_reverse_frame": 175,
    "screws_frame": 183,
    "screweyes_frame": 184,
    "dring_frame": 185,
    "backing_board_presence": 188,
    "surface_dirt_frame": 192,
    "accretions_frame": 193,
    "abrasions_frame": 194,
    "flaking_frame": 195,
    "losses_frame": 196,
    "dented_frame": 197,
    "chipped_frame": 198,
    "cracking_frame": 199,
    "corner_damage_frame": 200,
    "mitres_separating_frame": 201,
    "work_loose_frame": 202,
    "surface_dirt_along_top_edge_frame": 203,
}

CategoricalColumnsDict = {
    "accession_number": [0],
    "title": [12],
    "date": [13],
    "country": [14],
    "collection": [15],
    "sight": [7],
    "support_type": [46, 47, 48, 49],
    "commentary_auxiliary_support": [64],
    "wood_type_hardness": [76],
    "wood_type_country_locality": [77, 78, 79],
    # "wood_type": [77],
    # "wood_type_country": [78],
    # "wood_type_locality": [79],
    "media_type_1": [112],
    "media_type_2": [113],
    "media_type_3": [114],
    "ground_layer_application": [120, 121],
    "ground_layer_limit": [129, 130],
    "ground_layer_thickness": [123, 124],
    "relationship_cracks_aux_support": [157],
    "frame_material": [162, 163],
    "slip_presence_frame": [169, 170],
    "glazed_frame": [171, 172],
    "frame_affixed_to_wall_by": [177, 178, 179, 180],
    "frame_hanging_system": [181, 182],
    "frame_strand_wire": [186, 187],
    "backing_board_type": [189, 190, 191],
}

MultipleValuesCatColDict = {
    # format is "name_of_the_column":(index, number of columns we want to split it into)
    "cracks_mechanically_induced": (158, 5),
    "location_of_cracks": (160, 2),
    "environmental_history": (161, 8),
}

OrdinalColumnsDict = {
    "auxiliary_support_condition": [65, 66, 67, 68],
    "media_condition": [90, 91, 92, 93],
    "ground_condition": [115, 116, 117, 118],
    "painting_support_condition": [132, 133, 134, 135],
    "frame_condition": [205, 206, 207, 208],
}


def main(dataFile):
    cleanDataDf = pd.DataFrame()
    originalDataDf = pd.read_excel(dataFile)

    for feature in CategoricalColumnsDict:
        if feature == "relationship_cracks_aux_support":
            cleanDataDf[
                "corner_relationship_cracks_and_aux_support"
            ] = createCornerRelationCracksColumn(
                originalDataDf, CategoricalColumnsDict[feature]
            )
            cleanDataDf[
                "parallel_relationship_cracks_and_aux_support"
            ] = createParallelRelationCracksColumn(
                originalDataDf, CategoricalColumnsDict[feature]
            )

        elif feature == "wood_type_country_locality":
            (
                cleanDataDf["wood_type"],
                cleanDataDf["wood_country"],
                cleanDataDf["locality"],
            ) = processWoodType(originalDataDf, CategoricalColumnsDict[feature])

        else:
            cleanDataDf[feature] = fuseCategColumns(
                originalDataDf, CategoricalColumnsDict[feature], feature
            )
            if feature == "collection":
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([sS]ingapore).*",
                    value="Heritage Conservation Board (Singapore)",
                    regex=True,
                )
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([mM]alaysia).*",
                    value="National Art Gallery (Malaysia)",
                    regex=True,
                )
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([pP]hilippines).*",
                    value="Vargas Museum (Philippines)",
                    regex=True,
                )
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([bB]angkok).*",
                    value="National Gallery (Thailand)",
                    regex=True,
                )
            elif feature == "sight":
                (
                    cleanDataDf["length"],
                    cleanDataDf["width"],
                    cleanDataDf["area"],
                ) = computeLenWidthAndArea(cleanDataDf, feature)
            elif feature == "date":
                cleanDataDf["decade"] = transformDatesToDecades(cleanDataDf, feature)

    for feature in MultipleValuesCatColDict:
        (index, ncol) = MultipleValuesCatColDict[feature]
        dfList = splitMultivalueFeature(originalDataDf, index, ncol)
        for i in range(ncol):
            cleanDataDf[f"{feature}_{i+1}"] = dfList[i]

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
    # Triggers the warning: "PerformanceWarning: DataFrame is highly fragmented.  This is usually the result of calling `frame.insert` many times, which has poor performance.  Consider joining all columns at once using pd.concat(axis=1) instead.  To get a de-fragmented frame, use `newframe = frame.copy()`"
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
    existingCatDf = newColumn[colName]
    for index in indexList[1:]:
        additionalCatdF = originalDf.iloc[:, index]

        # 2 boolean series to tag the empty cells
        nonEmptAddCat = additionalCatdF != ""
        nonEmptExistingCat = existingCatDf != ""

        # Updating newCol
        existingCatDf[(nonEmptAddCat) & (nonEmptExistingCat)] = "both"
        existingCatDf[(nonEmptAddCat) & ~(nonEmptExistingCat)] = additionalCatdF[
            ~(nonEmptExistingCat)
        ]

        # newColumn[colName][
        #    newColumn[colName][originalDf.iloc[:, index] != ""] != ""
        # ] = "both"
        # newColumn[colName][newColumn[colName] == ""] += originalDf.iloc[:, index][
        #    newColumn[colName] == ""
        # ]
    existingCatDf = existingCatDf.replace(to_replace="", value="Unspecified")
    return existingCatDf


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
    nonEmptyLenWidDf = lengthWidthDf.fillna(0).astype(
        float
    )  # transforms nans into 0s (nans are rows where there is a missing value for 'sight')
    return (
        nonEmptyLenWidDf.iloc[:, 0],
        nonEmptyLenWidDf.iloc[:, 1],
        nonEmptyLenWidDf.iloc[:, 0] * nonEmptyLenWidDf.iloc[:, 1],
    )


def createCornerRelationCracksColumn(oldDataframe, index):
    """
    Read the information in the `Relationship of cracks to aux. support` column and create the column of `corner cracks`.
    The values of this new column can either be none, circle or bissector, depending on the information in the original table.
    """
    oldDataSeries = oldDataframe.iloc[:, index].squeeze()
    cornerInfoDf = oldDataSeries.str.extract(r"corner\s*(\S+)", expand=False)
    nonEmptCornerInfoDf = cornerInfoDf.fillna("Unspecified").astype(
        str
    )  # transforms nans into "Unspecified" (nans are rows where no match was found)
    nonEmptCornerInfoDf = nonEmptCornerInfoDf.replace(
        to_replace="", value="Unspecified"
    )
    return nonEmptCornerInfoDf


def createParallelRelationCracksColumn(oldDataframe, index):
    """
    Read the information in the `Relationship of cracks to aux. support` column and create the column of `parallel cracks`.
    The values of this new column can either be none, top member, to all edges, vertical members, bottom member, crossbar or horizontal, depending on the information in the original table.
    """
    oldDataSeries = oldDataframe.iloc[:, index].squeeze()
    paraInfoDf = oldDataSeries.str.extract(
        r"(?:parallel|paarellel).+(top|bottom|right|left|hoizontal|vertical|all|cross)",
        expand=False,
    )
    nonEmptParaInfoDf = paraInfoDf.fillna("Unspecified").astype(
        str
    )  # transforms nans into "none" (nans are rows where no match was found)
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("cross", "cross bar")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("all", "all edges")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("hoizontal", "horizontal members")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("vertical", "vertical members")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("top", "top member")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("bottom", "bottom member")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("left", "left member")
    nonEmptParaInfoDf = nonEmptParaInfoDf.str.replace("right", "right member")

    nonEmptParaInfoDf = nonEmptParaInfoDf.replace(to_replace="", value="Unspecified")
    return nonEmptParaInfoDf


def processWoodType(df, indexList):
    """
    Process the information in the wood type column: sometimes, the locality and the country of the wood is included in this column.
    The goal of this script is to redirect this information into the wood locality and wood country columns, keeping uniquely the actual wood type in the wood type column.
    """
    woodTypeDf = df.iloc[:, indexList[0]].copy()
    woodCountryDf = df.iloc[:, indexList[1]].copy()
    woodLocDf = df.iloc[:, indexList[2]].copy().fillna("")

    strExtractDf = (
        woodTypeDf.str.extract(r"((.*?)(local\?))?(.*)", expand=False)
        .fillna("")
        .astype(str)
    )
    # This regex capture the 3 groups woodType, locality and country when they exist when "local?" exists but put the wood type into the last group when there is no "local?"
    # It thus needs another filtering on country
    woodTypeDf = strExtractDf.iloc[:, 1]
    woodLocDf = woodLocDf + strExtractDf.iloc[:, 2]

    countryList = [
        "Malay",
        "Philippines",
        "Singapore",
        "Thailand",
        " Malay",
        " Philippines",
        " Singapore",
        " Thailand",
    ]

    # Extract countries that were not catch in the preceeding step
    extraCountriesDf = strExtractDf.iloc[:, 3].copy().str.strip()
    extraCountriesDf[~(extraCountriesDf.isin(countryList))] = np.nan
    extraCountriesDf = extraCountriesDf.fillna("")

    extraWoodTypeDf = strExtractDf.iloc[:, 3].copy()
    extraWoodTypeDf[extraWoodTypeDf.isin(countryList)] = np.nan
    extraWoodTypeDf = extraWoodTypeDf.fillna("")

    woodTypeDf = woodTypeDf.fillna("") + extraWoodTypeDf
    woodCountryDf = woodCountryDf.fillna("") + extraCountriesDf

    woodTypeDf = woodTypeDf.replace(to_replace="", value="Unspecified")
    woodCountryDf = woodCountryDf.replace(
        to_replace="", value="Unspecified"
    ).str.strip()
    woodLocDf = woodLocDf.replace(to_replace="", value="Unspecified")

    return (woodTypeDf, woodCountryDf, woodLocDf)


def splitMultivalueFeature(df, index, nbCol):
    """
    Returns n different columns extracted from the column given in index
    """
    oldDataSeries = df.iloc[:, index].squeeze()
    crackLocDf = oldDataSeries.str.split(pat="_x001D_", expand=True)
    nonEmptyCrackLocDf = crackLocDf.fillna("Unspecified").astype(str)
    nonEmptyCrackLocDf = nonEmptyCrackLocDf.replace(to_replace="", value="Unspecified")

    dfList = []
    for i in range(nbCol):
        dfList.append(nonEmptyCrackLocDf.iloc[:, i])

    return dfList


def transformDatesToDecades(df, feature):
    """
    Extract all the dates from the date column and display the decade they are in.
    If the format of the "date" record is "dddd - dddd", it computes the averages of both dates and shows the decade of the average.
    """
    # First we separate the record with a "dddd-dddd" format into two columns
    allDatesDf = df[feature].str.extract(r"(\d{4})(?:-(\d{4}))*", expand=False)
    nonEmptyAllDatesDf = allDatesDf.fillna(0).astype(float)
    # Then we regroup everything into one column of average
    avgDatesDf = (
        nonEmptyAllDatesDf.iloc[:, 0] + nonEmptyAllDatesDf.iloc[:, 0:2].max(axis=1)
    ) / 2

    # Transform the result into the decade
    dividedDf = avgDatesDf / 10
    flooredDf = dividedDf.apply(math.floor)
    decadDf = flooredDf * 10
    return decadDf.astype(int)


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
