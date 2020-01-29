#!/usr/bin/env python3
from statistics import mean, stdev
import os

"""
Set main parameters.
> working_dir
> analysis_dir
> pdbs_dir
> mass_dir
> runtime_dir
> debug
"""
working_dir = "/home/jvsguerra/KVpaper/kv1000-brasil"
analysis_dir = "analysis"
pdbs_dir = "kv1000/pdbs"
mass_data = "kv1000/data/kv1000_information.txt"
runtime_dir = "runtime"
debug = True

# Get molecular mass of domains in kv1000
def get_molecular_mass(mass_data) -> dict:

	# Create dict
	mm = dict()

	with open(mass_data, "r") as f_mm:
		# Skip first line (HEADERS)
		next(f_mm)
		# Read line by line
		for line in f_mm:
			mm[line.split('\t')[0]] = line.split('\t')[1]

	return mm


# Count number of atoms in PDB
def count_atoms(pdbs_dir) -> dict:
	from pymol import cmd

	# Create dict
	atom_dict = dict()

	for f in os.listdir(pdbs_dir):
		if f.find('.pdb') != -1:
			cmd.load(f"{pdbs_dir}/{f}", "f")
			n = cmd.count_atoms("f")
			atom_dict[f.replace(".pdb", "")] = n
			cmd.remove("f")

	return atom_dict


# Remove outliers function
def remove_outliers(time_data):
	flag = False
	avg = mean(time_data)
	std = stdev(time_data)

	for t in time_data:
		if abs(avg-t) > std:
			time_data.remove(t)
			flag = True

	if flag:
		return remove_outliers(time_data)
	else:
		return avg, std, time_data


if __name__ == "__main__":

	# Change working directory
	os.chdir(working_dir)

	# Get molecular mass of pdbs from kv1000
	molecular_mass = get_molecular_mass(mass_data)

	# Get number of atoms of pdbs from kv1000
	number_of_atoms = count_atoms(pdbs_dir)

	# Open results file
	with open(f"{working_dir}/{analysis_dir}/data/runtime_kv1000-brasil_parKVFinder_1-24threads.txt", "w") as output_file:

		# Write headers
		output_file.write("threads\tPDB_ID\tchain\tatoms\tmm_Da\truntime\tstdev\n")

		for dir in sorted(os.listdir(runtime_dir)):

			# Prepare data
			if dir.find("cores") != -1:
				threads = int(dir.replace("cores", ""))
				software = "parKVFinder"
			else:
				break

			# Print processing directory
			if debug:
				print(f"> Processing results of {software} {threads} threads")

			# Read files inside dir
			for f in os.listdir(f"{runtime_dir}/{dir}"):

				if f.find('.csv') != -1:

					#if debug:
					#	print(f"[===> {f}")

					with open(f"{runtime_dir}/{dir}/{f}", "r") as data:
						# Get PDB ID
						id = f.split('_')[0]
						chain = f.split('_')[1]

						# Get time data
						times = [float(i) for i in data.read().rstrip().split("\n")]

						avg, std, times = remove_outliers(times)

						# Write time data to output file
						n = number_of_atoms[f"{id}_{chain}"]
						mm = molecular_mass[f"{id}_{chain}"]
						output_file.write(f"{threads}\t{id}\t{chain}\t{n}\t{mm}\t{avg}\t{std}\n")

