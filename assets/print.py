import win32ui
import win32con
import datetime

# Label content
product_name = "Kaas"
expiration = "Za  20 feb 11:07"
weg_op_label = "Weg op:"
staff_name = "Lisa"
now = datetime.datetime.now().strftime("%a %H:%M %d-%m-%Y")

# Printer setup
printer_name = "Argox D2-250 PPLB"
printer_dc = win32ui.CreateDC()
printer_dc.CreatePrinterDC(printer_name)
printer_dc.SetMapMode(win32con.MM_TEXT)
printer_dc.SetViewportOrg((0, 0))
printer_dc.StartDoc("Final Balanced Label")
printer_dc.StartPage()

# Layout config
max_width = 400  # ~5 cm wide
x_start = 10
y = 10
line_spacing = 6  # pixels between lines

# Font fitting helper
def fit_font(dc, text, initial_height, max_w, weight=700, name="Arial"):
    font_height = initial_height
    while font_height > 8:
        font = win32ui.CreateFont({
            "name": name,
            "height": font_height,
            "weight": weight
        })
        dc.SelectObject(font)
        text_width, _ = dc.GetTextExtent(text)
        if text_width <= max_w:
            return font
        font_height -= 1
    return font

# Product Name
font_title = fit_font(printer_dc, product_name, 55, max_width)
printer_dc.SelectObject(font_title)
printer_dc.TextOut(x_start, y, product_name)
y += printer_dc.GetTextExtent(product_name)[1] + line_spacing

# Horizontal Line
printer_dc.MoveTo((x_start, y))
printer_dc.LineTo((x_start + max_width, y))
y += 8

# "Weg op:"
font_label = fit_font(printer_dc, weg_op_label, 30, max_width, weight=400)
printer_dc.SelectObject(font_label)
printer_dc.TextOut(x_start, y, weg_op_label)
y += printer_dc.GetTextExtent(weg_op_label)[1] + line_spacing

# Date
font_exp = fit_font(printer_dc, expiration, 40, max_width, name="Courier New")
printer_dc.SelectObject(font_exp)
printer_dc.TextOut(x_start, y, expiration)
y += printer_dc.GetTextExtent(expiration)[1] + line_spacing

# Footer (name + print timestamp)
footer = f"{staff_name} {now}"
font_footer = fit_font(printer_dc, footer, 25, max_width, weight=400)
printer_dc.SelectObject(font_footer)
printer_dc.TextOut(x_start, y, footer)

# Done
printer_dc.EndPage()
printer_dc.EndDoc()
printer_dc.DeleteDC()