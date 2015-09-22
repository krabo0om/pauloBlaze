library(plotrix)
data <- data.frame(Slices=c(57, 33, 100), Registers=c(79,79,83), LUTs=c(108,129,155), LUTRAMs=c(49,49,56))
library(Cairo)
  mainfont <- "cmss"
  CairoFonts(regular = paste(mainfont,"style=Regular",sep=":"),
             bold = paste(mainfont,"style=Bold",sep=":"),
             italic = paste(mainfont,"style=Italic",sep=":"),
             bolditalic = paste(mainfont,"style=Bold Italic,BoldItalic",sep=":"))
  pdf <- CairoPDF

pdf("res_mod1.pdf", width = 9, height=5)
#setEPS()
#postscript("res_mod1.eps", width=9, height=5)
colors = c("#22AD36", "#7EC67F", "#9cb1db")
par(mar=par()$mar+c(2.1, 0, 0, 0), xpd=TRUE)
barp(data, names.arg=names(data), col=colors, main="Resource Usage Pico/PauloBlaze", xlab="Category", ylab="Usage Number")

legend(1, -60, c("Pico constrained", "Pico unconstrained", "PauloBlaze"), col=colors, fill=colors, ncol=3)

dev.off()
