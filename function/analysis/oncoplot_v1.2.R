# this script is for oincoplot drawing
# author: laojp
# time: 2023.04.14
# position: SYSUCC bioinformatic platform
# usage: oncoplot_drawing(onco=[maf_dataframe])
# unfinished

library(tidyverse)
library(dplyr)
library(stringr)
library(ComplexHeatmap)
library(RColorBrewer)

oncoplot_drawing <- function(onco,top=20){
  onco <- as_tibble(onco)
  
  necessary_col=c("Hugo_Symbol","Variant_Classification","Tumor_Sample_Barcode")
  for(i in necessary_col){
    if(any(str_detect(colnames(onco),i))){
      print(paste("check: ",i," is ok",sep=""))
    }
    else{
      print(paste(i," is loss",sep=""))
      stop("please check your maf file")
    }
  }
  
  # modify the variant classification into group and multi hit
  print(" | modify the variant classification into group and multi hit")
  onco_com <- onco %>% 
    dplyr::group_by(Tumor_Sample_Barcode, Hugo_Symbol) %>% 
    dplyr::mutate(variant_result=paste(unique(Variant_Classification),collapse=";")) %>%
    dplyr::mutate(variant=unlist(lapply(variant_result,function(x){
      if(length(unlist(strsplit(x,split=";")))>1){
        if(sum(!str_detect("Amp|Del",unlist(strsplit(x,split=";"))))>1){
          if(sum(str_detect("Amp|Del",unlist(strsplit(x,split=";"))))==0){
            return("multi_hit")
          }else if(sum(str_detect("Amp|Del",unlist(strsplit(x,split=";"))))>1){
            return("multi_hit;multi_event")
          }else{
            return(paste("multi_hit;",as.character(na.omit(str_extract("Amp|Del",unlist(strsplit(x,split=";"))))),sep=""))
          }
        }else{
          if(sum(str_detect("Amp|DEL",unlist(strsplit(x,split=";"))))>1){
            return(paste(paste(str_remove_all(unlist(strsplit(x,split=";")),"\\b(Amp|Del)\\b"),collapse=""),
                         ";multi_event",sep=""))
          }else{
            return(paste(paste(str_remove_all(unlist(strsplit(x,split=";")),"\\b(Amp|Del)\\b"),collapse=""),
                         ";",
                         paste(as.character(na.omit(str_extract("Amp|Del",unlist(strsplit(x,split=";"))))),collapse=";"),sep=""))
          }
        }
      }else{return(x)}}
    ))) %>%
    dplyr::select(c("Tumor_Sample_Barcode","Hugo_Symbol","variant")) %>%
    distinct()
  View(onco_com)
  
  # create the oncomatrix
  print(" | create the oncomatrix")
  onco_matrix <- table(onco_com$Hugo_Symbol,onco_com$Tumor_Sample_Barcode)
  for (i in 1:dim(onco_matrix)[2]) {
    temp=onco_matrix[,i]
    temp_name <- names(temp[temp==1])
    if(length(temp_name)>0){
      temp_maf <- onco_com[onco_com$Tumor_Sample_Barcode==colnames(onco_matrix)[i],]
      onco_matrix[match(temp_name,rownames(onco_matrix)),i] <- temp_maf$variant[match(temp_name,temp_maf$Hugo_Symbol)] 
    }
  }
  onco_matrix[onco_matrix==0] <- ""
  
  # order according to the mutation number
  print(" | order according to the mutation number")
  onco_matrix_row <- table(onco_com$Hugo_Symbol,onco_com$Tumor_Sample_Barcode) %>% 
    as.data.frame() %>% 
    dplyr::group_by(Var1) %>% 
    dplyr::summarise(n=sum(Freq)) %>%
    dplyr::arrange(desc(n))
  onco_matrix_col <- table(onco_com$Hugo_Symbol,onco_com$Tumor_Sample_Barcode) %>% 
    as.data.frame() %>% 
    dplyr::group_by(Var2) %>% 
    dplyr::summarise(n=sum(Freq)) %>%
    dplyr::arrange(desc(n))
  onco_matrix <- onco_matrix[match(onco_matrix_row$Var1,rownames(onco_matrix)),
                           match(onco_matrix_col$Var2,colnames(onco_matrix))] %>% as.matrix()
  onco_matrix <- matrix(onco_matrix, ncol = ncol(onco_matrix), dimnames = dimnames(onco_matrix))
  
  # oncoprint parameter
  print(" | oncoprint parameter")
  qual_col_pals=brewer.pal.info[brewer.pal.info$category == "qual",]#最多78种颜色
  col_vector=unlist(mapply(brewer.pal, qual_col_pals$maxcolors,rownames(qual_col_pals)))
  
  mutation_type <- unique(unlist(strsplit(paste(onco_com$variant,collapse=";"),split=";")))
  set.seed(10)
  mutation_type_col=sample(x=col_vector,size=length(mutation_type),replace = FALSE)
  names(mutation_type_col) <- mutation_type
  
  # 使用 for 循环将突变类型和颜色添加到 mutation_colors 向量中
  alter_fun <- list(background = alter_graphic("rect", fill = "#CCCCCC"))
  for (i in names(mutation_type_col)) {
    if(i %in% c("Amp","Del")){
      alter_fun[[i]] <- local({ # need to readed in local cause some problems in closet object, https://github.com/jokergoo/ComplexHeatmap/issues/1041
        color=mutation_type_col[i]
        function(x, y, w, h) {
          grid.rect(x, y, w - unit(1, "pt") * 2, h - unit(1, "pt") * 2, gp = gpar(fill = color, col = NA))
        }
      })
    }
    else{
      alter_fun[[i]] <- local({
        color=mutation_type_col[i]
        function(x, y, w, h) {
          grid.rect(x, y, w - unit(1, "pt") * 2, h - unit(1, "pt") * 15, gp = gpar(fill = color, col = NA))
        }
      })
    }
  }
  
  # draw the oncoplot
  print(" | draw the oncoplot")
  set.seed(100)
  print(onco_matrix)
  oncoPrint(onco_matrix[1:top,], alter_fun = alter_fun, col = mutation_type_col, pct_side = "right", row_names_side = "left",
            heatmap_legend_param = list(title = "Alternations", at = names(mutation_type_col), labels = names(mutation_type_col)),
            pct_gp = gpar(fontsize = 14))
}
