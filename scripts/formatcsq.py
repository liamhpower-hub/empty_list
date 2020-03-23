#!/usr/bin/env python
# coding: utf-8


import csv
import sys 
import vcf
import argparse

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]

def getCsqHeader(vcf_file):
  reader = vcf.Reader(open(vcf_file, 'r'))
  csq_info = reader.infos['CSQ'].desc
  csq_header=csq_info.split("|")
  csq_header[0]=csq_header[0].split(" ")[-1]
  
  return(csq_header)

def modHeader(header_list):
    header_mod = []
        
    for item in header_list:
        sn = item[0].split(".")[0]
        output = "{}_[AD]:GQ:GT".format(sn)
        header_mod.append(output)
        
    return header_mod

def modRow(row_list):
    
    rest_mod = []
    for item in row_list:
        ad = item[0].split(",")
        ref = ad[0]
        non_ref_found = 0
            
        for allele_index in range(1,len(ad)):
            
            non_ref = int(ad[allele_index])
            
            if non_ref > 0:
                non_ref_found = 1
 
        if non_ref_found:
            joint_field = ":".join(list([item[0],item[2],item[3]]))
            rest_mod.append(joint_field)
        else:
            rest_mod.append("")
                
    return rest_mod

def replaceCsqHeader(tsv_in, tsv_out, csq_header):
    
    csv.field_size_limit(sys.maxsize)

    tsv_out_file = open(tsv_out,'w')
    
    with open(tsv_in,'r') as infile:
        reader = csv.reader(infile, delimiter='\t')
        header_found=0
    
        for line in reader:

            if (header_found == 0):
                header_found = 1
                csq_index = line.index("CSQ")
                final_header = line[0:csq_index]
                rest_of_header=line[csq_index+1:]
                rest_of_header_chunk = list(chunks(rest_of_header,4))
                rest_of_header_mod = modHeader(rest_of_header_chunk)

                final_header = final_header + csq_header + rest_of_header_mod
                tsv_out_file.write("\t".join(final_header))
                tsv_out_file.write("\n")

            else:
                non_csq = line[0:csq_index]
                rest=line[csq_index+1:]
                rest_chunk = list(chunks(rest,4))
                rest_mod = modRow(rest_chunk)

                csq_field = line[csq_index].split(",")

                for csq in csq_field:
                    final_csq = csq.split("|")
                    
                    # add this to skip csq = "NA"
                    if (final_csq[0] != 'NA'):
                        #print(final_csq)
                        final_line = non_csq + final_csq + rest_mod
                        tsv_out_file.write("\t".join(final_line))
                        tsv_out_file.write("\n")



def reformat(vcf_in,tsv_in):
    
    tsv_out = tsv_in.replace("tsv","formatcsq.tsv")
    csq_header = getCsqHeader(vcf_in)
    replaceCsqHeader(tsv_in, tsv_out, csq_header)
    

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-vcf", dest="vcf_in", help="input vcf file", required=True)
    parser.add_argument("-tsv", dest="tsv_in", help="input tsv file", required=True)
    args = parser.parse_args()

    return args.vcf_in, args.tsv_in


# main
vcf_in,tsv_in = parse_args()
reformat(vcf_in, tsv_in)

