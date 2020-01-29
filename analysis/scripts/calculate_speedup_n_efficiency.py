#!/usr/bin/env python3
import os

"""
Set main parameters.
> working_dir
> analysis_dir
> raw_time_data
> debug
"""
working_dir = "/home/jvsguerra/KVpaper/kv1000-brasil/analysis/data"
raw_time_data = "/home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/runtime_kv1000-brasil_parKVFinder_1-24threads.txt"
debug = True


def get_runtime_base(raw_time_data) -> dict:

	# Create dict
	time_1_thread = dict()

	with open(raw_time_data) as f:
		# Ignore first line
		next(f)
		for line in f:
			# Get number of threads
			nthreads = int(line.split('\t')[0])
			# If nthread equal 1, save data in dict
			if nthreads == 1:
				time = float(line.split('\t')[5])
				pdb = "{}_{}".format(line.split('\t')[1], line.split('\t')[2])
				time_1_thread[pdb] = time

	return time_1_thread


def calculate_speedup_n_efficiency(raw_time_data, base_time) -> list:

	# Create dict
	processed_time_data = list()

	with open(raw_time_data) as f:
		# Prepare new HEADERS
		processed_time_data.append("{}\tspeedup\tefficiency\n".format(f.readline().rstrip('\n')))

		# Read line by line
		for line in f:
			# Get data
			nthreads = int(line.split('\t')[0])
			pdb = "{}_{}".format(line.split('\t')[1], line.split('\t')[2])
			time = float(line.split('\t')[5])

			# Speedup and efficiency
			speedup = base_time[pdb]/time
			efficiency = speedup/nthreads

			# Append line to list
			processed_time_data.append("{}\t{}\t{}\n".format(line.rstrip('\n'), speedup, efficiency))

	return processed_time_data


if __name__ == "__main__":

	# Change working directory
	os.chdir(working_dir)

	# Get runtime of one thread for each pdbs of kv1000
	base_time = get_runtime_base(raw_time_data)

	# Calculate speedup and efficiency
	processed_time_data = calculate_speedup_n_efficiency(raw_time_data, base_time)

	# Write processed data
	with open("processed_time_data.txt", "w") as out:
		for line in processed_time_data:
			out.write(line)
