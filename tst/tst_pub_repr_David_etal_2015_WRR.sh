#!/bin/bash
#*******************************************************************************
#tst_pub_repr_David_etal_2015_WRR.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RRR pre- and post-processing steps used in the
#writing of:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015), Enhanced fixed-size parallel speedup with the Muskingum method using a 
#trans-boundary approach and a large sub-basins approximation, Water Resources 
#Research, 51(9), 1-25, 
#DOI: 10.1002/2014WR016650.
#The files used are available from:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015),
#xxx
#DOI: xx.xxxx/xxxxxx
#The following are the possible arguments:
# - No argument: all unit tests are run
# - One unique unit test number: this test is run
# - Two unit test numbers: all tests between those (included) are run
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2016-2017


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#N/A


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing files for: http://dx.doi.org/10.1002/2014WR016650"
echo "********************"


#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=99
     echo "Performing all unit tests: 1-99"
     echo "********************"
fi 
#Perform all unit tests if no options are given 

if [ "$#" = "1" ]; then
     fst=$1
     lst=$1
     echo "Performing one unit test: $1"
     echo "********************"
fi 
#Perform one single unit test if one option is given 

if [ "$#" = "2" ]; then
     fst=$1
     lst=$2
     echo "Performing unit tests: $1-$2"
     echo "********************"
fi 
#Perform all unit tests between first and second option given (both included) 

if [ "$#" -gt "2" ]; then
     echo "A maximum of two options can be used" 1>&2
     exit 22
fi 
#Exit if more than two options are given 


#*******************************************************************************
#Initialize count for unit tests
#*******************************************************************************
unt=0


#*******************************************************************************
#River network details
#*******************************************************************************

#-------------------------------------------------------------------------------
#Connectivity, base parameters, coordinates, sort
#-------------------------------------------------------------------------------
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating all domain files"
../src/rrr_riv_tot_gen_all_hydrosheds.py                                       \
     ../input/HSmsp_WRR/riv_HSmsp.shp                                          \
     4                                                                         \
     esri:102008                                                               \
     ../output/HSmsp_WRR/rapid_connect_HSmsp_tst.csv                           \
     ../output/HSmsp_WRR/kfac_HSmsp_1km_hour_tst.csv                           \
     ../output/HSmsp_WRR/xfac_HSmsp_0.1_tst.csv                                \
     ../output/HSmsp_WRR/sort_HSmsp_topo_tst.csv                               \
     ../output/HSmsp_WRR/coords_HSmsp_tst.csv                                  \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing connectivity"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/rapid_connect_HSmsp.csv                               \
     ../output/HSmsp_WRR/rapid_connect_HSmsp_tst.csv                           \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing kfac"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/kfac_HSmsp_1km_hour.csv                               \
     ../output/HSmsp_WRR/kfac_HSmsp_1km_hour_tst.csv                           \
     0.1                                                                       \
     10000                                                                     \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing xfac"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/xfac_HSmsp_0.1.csv                                    \
     ../output/HSmsp_WRR/xfac_HSmsp_0.1_tst.csv                                \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing sorted IDs"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/sort_HSmsp_topo.csv                                   \
     ../output/HSmsp_WRR/sort_HSmsp_topo_tst.csv                               \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing coordinates"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/coords_HSmsp.csv                                      \
     ../output/HSmsp_WRR/coords_HSmsp_tst.csv                                  \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Parameters 0
#-------------------------------------------------------------------------------
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating p_0 files"
../src/rrr_riv_tot_scl_prm.py                                                  \
     ../output/HSmsp_WRR/kfac_HSmsp_1km_hour.csv                               \
     ../output/HSmsp_WRR/xfac_HSmsp_0.1.csv                                    \
     0.406250                                                                  \
     0.296875                                                                  \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_0_tst.csv                        \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_0_tst.csv                        \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing k_0 files"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_0.csv                            \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_0_tst.csv                        \
     1e-6                                                                      \
     2e-2                                                                      \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing x_0 files"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_0.csv                            \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_0_tst.csv                        \
     1e-6                                                                      \
     2e-2                                                                      \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Parameters 1
#-------------------------------------------------------------------------------
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating p_1 files"
../src/rrr_riv_tot_scl_prm.py                                                  \
     ../output/HSmsp_WRR/kfac_HSmsp_1km_hour.csv                               \
     ../output/HSmsp_WRR/xfac_HSmsp_0.1.csv                                    \
     0.210876                                                                  \
     0.341400                                                                  \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_1_tst.csv                        \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_1_tst.csv                        \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing k_1 files"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_1.csv                            \
     ../output/HSmsp_WRR/k_HSmsp_pa_phi1_2008_1_tst.csv                        \
     1e-6                                                                      \
     2e-2                                                                      \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing x_1 files"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_1.csv                            \
     ../output/HSmsp_WRR/x_HSmsp_pa_phi1_2008_1_tst.csv                        \
     1e-6                                                                      \
     2e-2                                                                      \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Sorted subset
#-------------------------------------------------------------------------------
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating sorted basin file"
../src/rrr_riv_bas_gen_one_hydrosheds.py                                       \
     ../input/HSmsp_WRR/riv_HSmsp.shp                                          \
     ../output/HSmsp_WRR/rapid_connect_HSmsp.csv                               \
     ../output/HSmsp_WRR/sort_HSmsp_topo.csv                                   \
     ../output/HSmsp_WRR/riv_bas_id_HSmsp_topo_tst.csv                         \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing sorted basin file"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/riv_bas_id_HSmsp_topo.csv                             \
     ../output/HSmsp_WRR/riv_bas_id_HSmsp_topo_tst.csv                         \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Contributing catchment information
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating catchment file"
../src/rrr_cat_tot_gen_one_hydrosheds.py                                       \
     ../input/HSmsp_WRR/na_riv_15s.dbf                                         \
     ../output/HSmsp_WRR/rapid_catchment_na_riv_15s_tst.csv                    \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing catchment file"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/rapid_catchment_na_riv_15s.csv                        \
     ../output/HSmsp_WRR/rapid_catchment_na_riv_15s_tst.csv                    \
     1e-5                                                                      \
     1e-3                                                                      \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi

#*******************************************************************************
#Process Land surface model (LSM) data
#*******************************************************************************
#To be added


#*******************************************************************************
#Coupling
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create coupling file
#-------------------------------------------------------------------------------
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/x"
run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Creating coupling file"
../src/rrr_cpl_riv_lsm_lnk.py                                                  \
     ../output/HSmsp_WRR/rapid_connect_HSmsp.csv                               \
     ../output/HSmsp_WRR/rapid_catchment_na_riv_15s.csv                        \
     ../output/HSmsp_WRR/NLDAS_VIC0125_H.A20000101.0000.002.nc                 \
     ../output/HSmsp_WRR/rapid_coupling_HSmsp_tst.csv                          \
     > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing coupling file"
./tst_cmp_csv.py                                                               \
     ../output/HSmsp_WRR/rapid_coupling_HSmsp.csv                              \
     ../output/HSmsp_WRR/rapid_coupling_HSmsp_tst.csv                          \
     > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $run_file
rm -f $cmp_file
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Create volume file
#-------------------------------------------------------------------------------
#To be added


#*******************************************************************************
#Clean up
#*******************************************************************************
rm -f ../output/HSmsp_WRR/*_tst.csv


#*******************************************************************************
#End
#*******************************************************************************
echo "Passed all tests!!!"
echo "********************"
