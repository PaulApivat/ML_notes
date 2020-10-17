
import dash
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
import pandas as pd
import plotly.express as px

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__)#, external_stylesheets=external_stylesheets)

## data preparation
df = pd.read_csv('Online_Retail.csv')

df['Amount'] = df['Quantity'] * df['UnitPrice']
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])
df['Date'] = df['InvoiceDate'].dt.date
df['CustomerID'] = df['CustomerID'].astype(str)
df['Month'] = df['Date'].apply(lambda x : x.replace(day=1))

monthly_sales = df.groupby(by = 'Month').agg({'Amount' : 'sum',
                                              'CustomerID' : 'nunique',
                                              'InvoiceNo' : 'nunique'})
monthly_sales['TicketSize'] = monthly_sales['Amount'] / monthly_sales['InvoiceNo']
monthly_sales.columns = ['Amount', 'TotalCustomer', 'TotalTicket', 'TicketSize']
monthly_sales.reset_index(inplace=True)

country_sales = df.groupby(by=['Country'])[['Amount']].sum()\
                        .reset_index()\
                        .sort_values(by='Amount', ascending=True)
country_sales_no_uk = country_sales[country_sales['Country']!= 'United Kingdom']

product_sales = df.groupby(by=['Description'])[['Amount','Quantity']].sum()

## plots

fig1 = px.line(monthly_sales, x='Month', y='Amount', height=400, title='Amount')
fig2 = px.line(monthly_sales, x='Month', y='TotalCustomer', height=400, title='Total Customer')
fig3 = px.line(monthly_sales, x='Month', y='TicketSize', height=400, title='Ticket Size')
fig4 = px.scatter(product_sales, x='Quantity', y='Amount', height=400, title='Product Portfolio')
fig5 = px.bar(country_sales_no_uk, x='Amount', y='Country', height=800, orientation='h', title='Country Comparison')

## dash app

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
body = html.Div([html.H1("Online Retail Dashboard - Edit")
  , dbc.Row([
      dbc.Col(
          dbc.Row(html.Div(dcc.Graph(figure=fig1))) 
        , width = 4),
      dbc.Col(
          dbc.Row(html.Div(dcc.Graph(figure=fig4)))
          )
  ])
  , dbc.Row([
      dbc.Col([
          dbc.Row(html.Div(dcc.Graph(figure=fig2))),
          dbc.Row(html.Div(dcc.Graph(figure=fig3)))    
        ], width = 4),
      dbc.Col(
          dbc.Row(html.Div(dcc.Graph(figure=fig5)))    
        )
  ])
])  
app.layout = html.Div([body])

if __name__ == "__main__":
    app.run_server(debug = True)
