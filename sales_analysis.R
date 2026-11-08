# AI Assistance Declaration:
# I used ChatGPT (GPT-6, OpenAI; 1–7 November 2026) for project ideation,
# code-organization suggestions, and documentation support. Key prompts are
# summarized in Appendix.md. I reviewed this script, but it still needs to be
# run and its outputs inspected in my R environment before submission. I am
# responsible for the accuracy and originality of this work.

# Synthetic Retail Sales Analysis

# Check the required package before starting.
required_packages <- c("ggplot2")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Install ggplot2 first with install.packages(\"ggplot2\")")
}
library(ggplot2)

# Generate reproducible fictional data only.
set.seed(400)
months <- seq.Date(as.Date("2025-01-01"), by = "month", length.out = 12)
products <- data.frame(
  product = c("Headphones", "Desk Lamp", "T-shirt"),
  category = c("Electronics", "Home", "Clothing"),
  unit_price = c(80, 35, 25),
  base_units = c(42, 55, 70)
)

sales <- expand.grid(month = months, product = products$product)
sales <- merge(sales, products, by = "product", sort = FALSE)
sales <- sales[order(sales$month, match(sales$product, products$product)), ]
sales$units_sold <- pmax(1, round(sales$base_units + rnorm(nrow(sales), 0, 8)))
sales$revenue <- sales$units_sold * sales$unit_price

# Create summaries by month, category, and product.
monthly_sales <- aggregate(revenue ~ month, sales, sum)
category_sales <- aggregate(cbind(units_sold, revenue) ~ category, sales, sum)
product_sales <- aggregate(cbind(units_sold, revenue) ~ product, sales, sum)
category_sales <- category_sales[order(-category_sales$revenue), ]
product_sales <- product_sales[order(-product_sales$revenue), ]

cat("\nSYNTHETIC RETAIL SALES SUMMARY\n")
cat("Total revenue: $", format(sum(sales$revenue), big.mark = ","), "\n", sep = "")
cat("Total units sold: ", sum(sales$units_sold), "\n", sep = "")
cat("\nRevenue by category:\n")
print(category_sales, row.names = FALSE)
cat("\nTop product by revenue:\n")
print(product_sales[1, ], row.names = FALSE)

# Create the output folder if it does not already exist.
dir.create("output", showWarnings = FALSE)

# Plot monthly revenue.
monthly_plot <- ggplot(monthly_sales, aes(month, revenue)) +
  geom_line(linewidth = 0.8, colour = "#2463A6") +
  geom_point(size = 2, colour = "#2463A6") +
  labs(title = "Monthly Retail Revenue", x = "Month", y = "Revenue ($)") +
  theme_minimal()

# Plot revenue by product category.
category_plot <- ggplot(category_sales, aes(reorder(category, revenue), revenue)) +
  geom_col(fill = "#3A8D75") +
  coord_flip() +
  labs(title = "Revenue by Product Category", x = "Category", y = "Revenue ($)") +
  theme_minimal()

# Save charts and CSV outputs.
ggsave("output/monthly_revenue.png", monthly_plot, width = 8, height = 5, dpi = 300)
ggsave("output/category_revenue.png", category_plot, width = 8, height = 5, dpi = 300)
write.csv(sales, "output/synthetic_retail_sales.csv", row.names = FALSE)
write.csv(monthly_sales, "output/monthly_sales_summary.csv", row.names = FALSE)
write.csv(category_sales, "output/category_sales_summary.csv", row.names = FALSE)

cat("\nFiles saved in output/.\n")
