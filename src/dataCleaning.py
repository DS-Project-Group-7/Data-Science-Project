from ast import Break
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
    "striped_frame": 165,
    "carved_frame": 166,
    "gesso_moldings_on_frame": 167,
    "painted_or_stained_frame": 168,
    "gilded_frame": 169,
    "glass_frame": 174,
    "perspex_frame": 175,
    "unable_to_examine_reverse_frame": 176,
    "screws_frame": 184,
    "screweyes_frame": 185,
    "dring_frame": 186,
    "backing_board_presence": 189,
    "surface_dirt_frame": 193,
    "accretions_frame": 194,
    "abrasions_frame": 195,
    "flaking_frame": 196,
    "losses_frame": 197,
    "dented_frame": 198,
    "chipped_frame": 199,
    "cracking_frame": 200,
    "corner_damage_frame": 201,
    "mitres_separating_frame": 202,
    "work_loose_frame": 203,
    "surface_dirt_along_top_edge_frame": 204,
}

CategoricalColumnsDict = {
    "accession_number": [0],
    "artist": [2],
    "canvas": [210],
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
    # "relationship_cracks_aux_support": [157],
    "frame_material": [163, 164],
    "slip_presence_frame": [170, 171],
    "glazed_frame": [172, 173],
    "frame_affixed_to_wall_by": [178, 179, 180, 181],
    "frame_hanging_system": [182, 183],
    "frame_strand_wire": [187, 188],
    "backing_board_type": [190, 191, 192],
}

MultipleValuesCatColDict = {
    # format is "name_of_the_column":(index, max number of values that are not in the list, list of possible values)
    "relationship_cracks_aux_support": (
        157,
        2,
        [
            "corner bisector crack (keying out)",
            "corner circle (quadrant) cracks (stress at corners)",
            "parallel to bottom member",
            "parallel to top member",
            "parallel to right member",
            "parallel to left member",
            "parallel to hoizontal members",
            "parallel to vertical members",
            "parallel to all edges",
            "parallel to cross bars",
        ],
    ),
    "cracks_mechanically_induced": (
        158,
        2,
        [
            "local",
            "overall",
            "secondary horizontal and vertical",
            "primary horizontal and vertical",
            "secondary horizontal",
            "secondary vertical",
            "primary vertical",
            "primary horizontal",
            "primary diagonal",
            "secondary diagonal",
            "solid support expanding: minor",
            "solid support expanding: major",
            "large network of cracks",
            "tight network of small cracks",
            "local grid cracks (follows canvas weave)",
            "overall grid cracks (follows canvas weave) ",
            "local net cracks (primary cracks= secondary cracks)",
            "overall net cracks (primary cracks= secondary cracks)",
            "corn ear crack (from front)",
            "tented paint due to stretched support",
            "tented paint due to compressed support",
            "blind cleavage due to water damage",
            "due to loss of tension at bottom",
            "tacking garland cracks",
            "middle bisector cracks",
            "stretcher bar ladder cracks",
            "sigmoud cracks",
            "herringbone cracks (from back)",
            "cracks in thin paint",
            "cracks in thick paint",
            "local loss of cohesion in binder",
            "local brittle paint",
            "very brittle paint throughout",
            "overall loss of cohesion in binder",
            "due to changes or previous treatment",
        ],
    ),
    "drying_cracks_the_paint_itself": (
        159,
        2,
        [
            "overall",
            "local",
            "large network of cracks",
            "tight network of small cracks",
            "small evaporation holes",
            "spiral cracks",
            "cracks in whites",
            "cracks in darks",
            "cracks in thin paint",
            "cracks in thick paint",
            "buckling drying cracks",
            "alligator drying cracks",
            "brushstroke crack",
            "grid crack ",
            "net cracks (irregular, primary cracks = secondary cracks)",
            "flame cracks (short cracks)",
        ],
    ),
    "description_of_paint_loss": (
        160,
        2,
        [
            "at the ground layer no dark shadows",
            "at the support layer",
            "at the interlayer",
            "at the surface layer",
            "losses due to external mechanical damage",
            "at the support layer due to moisture delamination",
            "overall large network of paint loss",
            "overall tight network of paint loss",
            "local large network of paint loss",
            "local tight network of paint loss",
        ],
    ),
    "location_of_cracks": (
        161,
        2,
        [
            "at the ground layer, no dark shadows visble",
            "at the support layer, dark shadows visible",
            "at the interlayer",
            "at the surface layer",
            "along the bottom edge",
            "along the bottom and top edge",
            "along the side edges",
            "along the top edge",
            "in the upper half",
            "in the lower half",
        ],
    ),
    "environmental_history": (
        162,
        2,
        [
            "24 hours air conditioning, values unknown",
            "24 hours air conditioning at 22 degrees+2 degrees, 60% RH+5% RH",
            "work hours airconditioning at 22 degrees+2 degrees, 50% RH+5% RH, off overnight",
            "manually regulated airconditioning for humman comfort",
            "manually regulated airconditionin for artworks",
            "no air conditioning, climate monitored & stable",
            "no air conditioning, climate monitored & unstable",
            "in current conditions for years",
            "prior storage/ display conditions in private home",
            "prior storage/ display coniditons in private museum",
            "prior storage display conditions unknown",
        ],
    ),
}

MultipleValuesLists = {
    "cracks_mechanically_induced": [],
    "location_of_cracks": [],
    "environmental_history": ["no air conditioning, climate monitored & unstable"],
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
        elif feature == "canvas":
            cleanDataDf[feature] = cleanCanvasMaterial(
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
                    value="National Heritage Conservation Board (Singapore)",
                    regex=True,
                )
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([mM]alaysia).*",
                    value="Balai Seni Negara (Malaysia)",
                    regex=True,
                )
                cleanDataDf[feature] = cleanDataDf[feature].replace(
                    to_replace=".*([pP]hilippines).*",
                    value="JB Vargas Museum (Philippines)",
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
        (index, maxOther, values) = MultipleValuesCatColDict[feature]
        oldDataSeries = originalDataDf.iloc[:, index].squeeze()
        for value in values:
            cleanDataDf[feature + " : " + value] = oldDataSeries.str.contains(
                value, regex=False
            ).astype(int)
        # dfListOthers = findOtherValues(oldDataSeries, maxOther, values)
        # for i in range(maxOther):
        #    cleanDataDf[f"{feature}_other_{i+1}"] = dfListOthers[i]

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
        if colName == "ground_layer_application":
            existingCatDf[(nonEmptAddCat) & (nonEmptExistingCat)] = "unsure"
        else:
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
    return existingCatDf.str.title()


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

    for index in orderedIndexList:
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

    newColumn[colName] = newColumn[colName].replace(0, np.nan)
    newColumn[colName] = newColumn[colName] - 1
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


def cleanCanvasMaterial(oldDataframe, index):
    """
    Trim the information from the canvas column and only keep the material of the canvas
    """
    sparseDf = (
        oldDataframe.iloc[:, index].squeeze().str.findall(r"(linen)|(cotton)|(bast)")
    )
    materialDic = {"canvas": []}
    for i in range(len(sparseDf)):
        tupleList = sparseDf.iloc[
            i,
        ]
        isLinen = False
        isCotton = False
        isBast = False
        for tuple in tupleList:
            stopLook = False
            for element in tuple:
                if element == "linen":
                    isLinen = True
                elif element == "cotton":
                    isCotton = True
                elif element == "bast":
                    isBast = True
                if isBast * isCotton * isLinen:
                    materialDic["canvas"].append("linen and cotton and bast")
                    stopLook = True
                    break
            if stopLook:
                break
        if isLinen:
            if isCotton:
                materialDic["canvas"].append("linen and cotton")
            elif isBast:
                materialDic["canvas"].append("linen and bast")
            else:
                materialDic["canvas"].append("linen")
        elif isCotton:
            if isBast:
                materialDic["canvas"].append("cotton and bast")
            else:
                materialDic["canvas"].append("cotton")
        elif isBast:
            materialDic["canvas"].append("bast")
        else:
            materialDic["canvas"].append("unspecified")

    print(len(materialDic["canvas"]))
    finalDf = pd.DataFrame.from_dict(materialDic)
    return finalDf


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


def findOtherValues(oldDataSeries, n, values):
    """
    Returns n different columns extracted from the serie displaying the values that are not in the list of possible values
    """
    splittedDf = oldDataSeries.str.split(pat="_x001D_", expand=True)
    nonEmptySplittedDf = splittedDf.fillna("Unspecified").astype(str)
    nonEmptySplittedDf = nonEmptySplittedDf.replace(to_replace="", value="Unspecified")

    dfList = []
    for i in range(n):
        dfList.append(nonEmptySplittedDf.iloc[:, i])

    return dfList


# def createBinColumnValue(dataSeries, value):
# return (dataSeries.str.contains(value))


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
