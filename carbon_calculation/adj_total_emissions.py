import decimal as d

class AdjTotalComputer():
    
    def __init__(self, **kwargs):
        self.mu_purch = d.Decimal(kwargs.get("mu_purch", "0.5"))
        self.mu_max_purch = d.Decimal(kwargs.get("mu_max_purch", "0.8"))
        self.psi_prod = d.Decimal(kwargs.get("psi_prod", "0.05"))

    ## Specify Calculation Function
    def get_carbon_emissions(self, co_data):
        # co_data must be decimals already
        tot_m_ccv = co_data['Total CO2 Equivalents Emissions'] - co_data[
            'Carbon Credit Value']
        re_discounted = 1 - min(
            self.mu_purch*co_data[
                "Renewable Energy Purchased"]/co_data[
                    "Total Energy Use"], 
            self.mu_max_purch)
        prod_em = self.psi_prod*co_data["Renewable Energy Produced"]
        c_emissions = tot_m_ccv*re_discounted-prod_em
        return c_emissions