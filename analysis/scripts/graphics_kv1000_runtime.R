#!/usr/bin/env Rscript
library(ggplot2)
library(reticulate)

"
STEP 1: Compiling time data into a raw ggplot-compatible matrix.
- Compile time data of parKVFinder for directories inside /home/jvsguerra/KVpaper/kv1000-brasil/runtime

> Scripts: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/scripts/runtime_parKVFinder_analysis.py
> Inputs: 
- /home/jvsguerra/KVpaper/kv1000-brasil/kv1000/runtime/*/*.csv, 
- /home/jvsguerra/KVpaper/kv1000-brasil/kv1000/data/kv1000_information.txt
- /home/jvsguerra/KVpaper/kv1000-brasil/kv1000/pdbs/*.pdb
> Output: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/runtime_kv1000-brasil_parKVFinder_1-24threads.txt
"

# Change working directory
working_directory = "/home/jvsguerra/KVpaper/kv1000-brasil/analysis/scripts"
setwd(working_directory)

# Compile runtime data with python3 script
use_python("/usr/bin/python3", required = TRUE)
py_run_file("runtime_parKVFinder_analysis.py")

"
STEP 2: Processing compiled raw data. 
- Calculate speedup and efficiency.

> Scripts: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/scripts/calculate_speedup_n_efficiency.py
> Inputs: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/runtime_kv1000-brasil_parKVFinder_1-24threads.txt
> Output: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/processed_time_data.txt
"

# Change working directory
working_directory = "/home/jvsguerra/KVpaper/kv1000-brasil/analysis/scripts"
setwd(working_directory)

# Calculate speedup and efficiency from raw time data with python3 script
use_python("/usr/bin/python3", required = TRUE)
py_run_file("calculate_speedup_n_efficiency.py")

"
STEP 3: Create parallelization graphics (time, speedup and efficiency x number of threads).
- Process data in intervals of molecular mass
- Create each graphic (Fig. A: time, Fig. B: speedup, Fig. C: efficiency)

> Scripts: 
- None
> Inputs: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/runtime_kv1000_parKVFinder_1_to_24_threads.txt
> Output: 
- /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data/processed_data.txt
"

# Change working directory
working_directory = "/home/jvsguerra/KVpaper/kv1000-brasil/analysis/data"
setwd(working_directory)

# Read processed time data
processed_data = read.table("processed_time_data.txt", header = TRUE)

# Create molecular mass interval data.frame for ggplot2
"
> 8: number of type of threads used
> 17: number of molecular mass intervals
"
data = data.frame(
  "start" = rep(c(seq(9000, 73000, 4000)), 8),
  "end" = rep(c(seq(13000, 73000, 4000), Inf), 8),
  "threads" = c(rep(1, 17), rep(2, 17), rep(4, 17), rep(8, 17), rep(12, 17), rep(16, 17), rep(20, 17), rep(24, 17)),
  check.names = FALSE 
)
data$tag = paste(paste(paste(paste("[", data$start, sep = ""), ", ", sep = ""), data$end, sep = ""), ")", sep = "")
for (i in 1:dim(data)[1]) if (i %% 17 == 0) data$tag[i] = "[73000, ∞)"
data$runtime = NA
data$sd = NA
data$speedup = NA
data$efficiency = NA

# Get average runtime for each molecular mass interval and number of threads
for (i in 1:dim(data)[1]) {
  
  cat(paste("[==> Processing ", data[i,4], " interval for ", data[i, 3], " threads", sep = ""))
  cat("\n")
  
  flag = processed_data$mm_Da >= data$start[i] & processed_data$mm_Da < data$end[i] & processed_data$threads == data$threads[i]

  data$runtime[i] = mean(processed_data$runtime[flag])
  data$sd[i] = sd(processed_data$runtime[flag])
  data$speedup[i] = mean(processed_data$speedup[flag])
  data$efficiency[i] = mean(processed_data$efficiency[flag])

}

# Change working directory
working_directory = "/home/jvsguerra/KVpaper/kv1000-brasil/Figs/"
setwd(working_directory)

# Create each graphic (Fig. A: time, Fig. B: speedup, Fig. C: efficiency)

"
Fig. A. Time x Threads (per molecular mass interval)
"
figA <-
ggplot(data, aes(x = threads, y = runtime, colour = reorder(tag, end))) +
  geom_point(aes(color = tag)) +
  geom_line(aes(color = tag)) +
  stat_summary(fun.y = mean, geom = "line", color = "black", linetype = 1, size = 1.2) +
  
  # scale_color_manual(values = colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "black"))(17), limits = unique(data$tag)) +
  scale_color_manual(values = c(colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "darkgray"))(17), "black"),
                     limits = c(unique(data$tag), "Average")) +

  theme_bw() +
  scale_y_continuous(breaks = c(seq(0, 80, by = 5)), expand = c(0,0), limits = c(0, 76)) +
  scale_x_continuous(breaks = c(seq(1, 24, by = 1)), expand = c(0,0), limits = c(0.9, 24.1)) +
  labs(x = "Threads", y = "Time (s)", color = "Molecular mass (Da)") +
  theme(axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 18, hjust = 1),
        legend.text = element_text(size = 12)) +
  theme(axis.title.y = element_text(angle = 90, 
                                    hjust = 0.5, 
                                    size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_text(size = 12)) 

png("FigA - Time x Threads.png", width = 2800, height = 2100, res = 300)
figA
dev.off()  

"
Fig. B. Speedup x Threads (per molecular mass interval)
"
figB <-
  ggplot(data, aes(x = threads, y = speedup, colour = reorder(tag, end))) +
  geom_point(aes(color = tag)) +
  geom_line(aes(color = tag)) +
  stat_summary(fun.y = mean, geom = "line", color = "black", linetype = 1, size = 1.2) +
  
  # scale_color_manual(values = colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "black"))(17), limits = unique(data$tag)) +
  scale_color_manual(values = c(colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "darkgray"))(17), "black"),
                     limits = c(unique(data$tag), "Average")) +

  theme_bw() +
  scale_y_continuous(breaks = c(seq(1, 8, by = .5)), expand = c(0,0), limits = c(1, 8.1)) +
  scale_x_continuous(breaks = c(seq(1, 24, by = 1)), expand = c(0,0), limits = c(0.9, 24.1)) +
  labs(x = "Threads", y = "Speedup", color = "Molecular mass (Da)") +
  theme(axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 18, hjust = 1),
        legend.text = element_text(size = 12)) +
  theme(axis.title.y = element_text(angle = 90, 
                                    hjust = 0.5, 
                                    size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_text(size = 12)) 

png("FigB - Speedup x Threads.png", width = 2800, height = 2100, res = 300)
figB
dev.off()  

"
Fig. C. Efficiency x Threads (per molecular mass interval)
"
figC <-
  ggplot(data, aes(x = threads, y = efficiency*100, colour = reorder(tag, end))) +
  geom_point(aes(color = tag)) +
  geom_line(aes(color = tag)) +
  stat_summary(fun.y = mean, geom = "line", color = "black", linetype = 1, size = 1.2) +

  # scale_color_manual(values = colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "black"))(17), limits = unique(data$tag)) +
  scale_color_manual(values = c(colorRampPalette(c("red", "green", "cyan", "blue", "magenta", "darkgray"))(17), "black"),
                     limits = c(unique(data$tag), "Average")) +

  theme_bw() +
    scale_y_continuous(breaks = c(seq(0, 100, by = 5)), expand = c(0,0), limits = c(0, 101)) +
    scale_x_continuous(breaks = c(seq(1, 24, by = 1)), expand = c(0,0), limits = c(0.9, 24.1)) +
  labs(x = "Threads", y = "Efficiency (%)", color = "Molecular mass (Da)") +
  theme(axis.text.x = element_text(size = 14), 
        axis.text.y = element_text(size = 18, hjust = 1),
        legend.text = element_text(size = 12)) +
  theme(axis.title.y = element_text(angle = 90, 
                                    hjust = 0.5, 
                                    size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_text(size = 12)) 

png("FigC - Efficiency x Threads.png", width = 2800, height = 2100, res = 300)
figC
dev.off()  
