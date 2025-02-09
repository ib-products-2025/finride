from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime, timedelta  # Add timedelta import
import json
from pathlib import Path

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enhanced Pydantic Models
class KeyTopic(BaseModel):
    topic: str
    confidence: float

class ProductMatch(BaseModel):
    product: str
    confidence: float
    reasons: List[str]
    features: List[str]

class ConversationAnalysis(BaseModel):
    summary: List[str]
    keyTopics: List[KeyTopic]
    keywords: List[str]
    sentiment: Dict[str, Any]
    productMatches: List[ProductMatch]

class NextStep(BaseModel):
    action: str
    priority: str
    deadline: str
    status: str

class BusinessInsights(BaseModel):
    segment: str
    age: int 
    aum: float
    industry: str
    status: str

class Customer(BaseModel):
    phone_number: str
    name: str
    businessInsights: BusinessInsights
    financialGoals: List[str]
    nbo: Optional[List[ProductMatch]] = []
    nba: Optional[List[NextStep]] = []

class RideInteraction(BaseModel):
    id: int
    customer: Customer
    timestamp: str
    date: str
    platform: str
    analysisComplete: bool
    conversationAnalysis: Optional[ConversationAnalysis]
    nextSteps: List[NextStep]

class ComplianceCheckpoint(BaseModel):
    category: str
    items: List[Dict[str, Any]]

# In main.py, update the ComplianceCheck model:
class ComplianceCheck(BaseModel):
    status: str
    active_compliance_checks: List[Dict[str, Any]]
    previous_compliance_checks: List[Dict[str, Any]]
    guidelines: Dict[str, List[str]]

class DashboardMetrics(BaseModel):
    conversationMetrics: Dict[str, Dict[str, Any]]
    topTriggerWords: List[Dict[str, Any]]
    sentimentTrend: List[Dict[str, Any]]
    productRecommendations: List[Dict[str, Any]]
    customerSegments: List[Dict[str, Any]]

def load_data(file_path: str) -> Any:
    path = Path("data") / file_path
    with open(path, 'r') as f:
        return json.load(f)

def save_data(file_path: str, data: Any) -> None:
    path = Path("data") / file_path
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)

# Enhanced API Routes
@app.get("/customers")
async def get_customers():
    """Return all customers"""
    return load_data("customers.json")

@app.get("/customers/{phone_number}")
async def get_customer(phone_number: str):
    customers = load_data("customers.json")
    customer = next((c for c in customers if c["phone_number"] == phone_number), None)
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer

@app.post("/customers")
async def create_or_update_customer(customer: dict):
    phone_number = customer["phone_number"]
    customers = load_data("customers.json")
    
    # Use received data directly, no default values
    new_customer = {
        "phone_number": phone_number,
        "name": customer["name"],
        "businessInsights": customer["businessInsights"],
        "financialGoals": customer["financialGoals"],
        "nbo": customer.get("nbo", []),
        "nba": customer.get("nba", [])
    }

    existing = next((c for c in customers if c["phone_number"] == phone_number), None)
    if existing:
        existing.update(new_customer)
        updated_customer = existing
    else:
        customers.append(new_customer)
        updated_customer = new_customer
    
    save_data("customers.json", customers)
    return updated_customer

@app.post("/interactions")
async def create_interaction(interaction: dict):
   interactions = load_data("interactions.json")
   
   next_id = max([i["id"] for i in interactions], default=0) + 1
   
   new_interaction = {
       "id": next_id,
       "customer": interaction["customer"],
       "timestamp": interaction["timestamp"],
       "date": interaction["date"],
       "platform": interaction["platform"],
       "status": "high_potential",
       "analysisComplete": False,
       "conversationAnalysis": None,
       "nextSteps": [
           {
               "action": "Follow up call",
               "priority": "high",
               "deadline": (datetime.now() + timedelta(days=3)).strftime("%Y-%m-%d"),
               "status": "pending"
           }
       ]
   }
   
   interactions.append(new_interaction)
   save_data("interactions.json", interactions)

   # Create new compliance check
   compliance_data = load_data("compliance.json")
   
   new_compliance_check = {
       "interaction_id": next_id,
       "status": "in_review", 
       "checkpoints": [
           {
               "category": "Product Discussion",
               "items": [
                   {"text": "Clear product term disclosure", "required": True, "completed": False},
                   {"text": "Fee structure explanation", "required": True, "completed": False}, 
                   {"text": "Risk disclosure", "required": True, "completed": False}
               ]
           },
           {
               "category": "Customer Protection",
               "items": [
                   {"text": "Explicit consent obtained", "required": True, "completed": False},
                   {"text": "Data privacy maintained", "required": True, "completed": False}
               ]
           }
       ],
       "customer_name": interaction["customer"]["name"],
       "ride_date": interaction["date"]
   }

   compliance_data["active_compliance_checks"].append(new_compliance_check)
   save_data("compliance.json", compliance_data)
   
   return new_interaction

@app.get("/products")
async def list_products():
    return load_data("products.json")

@app.get("/interactions")
async def get_interactions() -> List[RideInteraction]:
    return load_data("interactions.json")

@app.post("/interactions/{ride_id}/analysis")
async def save_analysis(ride_id: int, analysis: ConversationAnalysis):
    interactions = load_data("interactions.json")
    interaction = next((i for i in interactions if i["id"] == ride_id), None)
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction not found")
    
    interaction["conversationAnalysis"] = analysis.dict()
    interaction["analysisComplete"] = True
    save_data("interactions.json", interactions)
    return {"message": "Analysis saved successfully"}

@app.get("/compliance/current-ride")
async def get_compliance() -> ComplianceCheck:
    base_compliance = load_data("compliance.json")
    interactions = load_data("interactions.json")
    
    # Enhance active checks with interaction data
    for check in base_compliance["active_compliance_checks"]:
        interaction = next((i for i in interactions if i["id"] == check["interaction_id"]), None)
        if interaction:
            check["customer_name"] = interaction["customer"]["name"]
            check["ride_date"] = interaction["date"]
    
    # Enhance previous checks
    for check in base_compliance["previous_compliance_checks"]:
        interaction = next((i for i in interactions if i["id"] == check["interaction_id"]), None)
        if interaction:
            check["customer_name"] = interaction["customer"]["name"]
            check["ride_date"] = interaction["date"]
    
    return base_compliance

@app.post("/compliance/current-ride")
async def update_compliance(compliance: ComplianceCheck):
    save_data("compliance.json", compliance.dict())
    return compliance

@app.get("/analytics/dashboard")
async def get_dashboard_analytics() -> DashboardMetrics:
    return load_data("dashboard.json")

@app.get("/customers/{phone_number}/interactions")
async def get_customer_interactions(phone_number: str):
    interactions = load_data("interactions.json")
    customer_interactions = [i for i in interactions if i["customer"]["phone_number"] == phone_number]
    if not customer_interactions:
        raise HTTPException(status_code=404, detail="No interactions found")
    return customer_interactions

@app.post("/customers/{phone_number}/interactions")
async def add_interaction(phone_number: str, interaction: Dict[str, Any]):
    interactions = load_data("interactions.json")
    interaction["customer"]["phone_number"] = phone_number
    interactions.append(interaction)
    save_data("interactions.json", interactions)
    return interaction