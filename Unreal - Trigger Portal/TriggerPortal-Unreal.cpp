#include "TriggerPortal.h"
#include "FPCharacter.h"
#include "Components/BoxComponent.h"
#include "DrawDebugHelpers.h"

ATriggerPortal::ATriggerPortal() {
	//Private Variables
	playerActor = NULL;
	moveVector = FVector(0.f, 10000.f, 0.f);
	//Public Variables
	posYEntrance = false;
	movePlayer = false;
	inTrigger = false;
	distanceToTeleport = 1500.f;
	//Register Events
	OnActorBeginOverlap.AddDynamic(this, &ATriggerPortal::OnOverlapBegin);
	OnActorEndOverlap.AddDynamic(this, &ATriggerPortal::OnOverlapEnd);
	PrimaryActorTick.bCanEverTick = true;
}

void ATriggerPortal::Tick(float DeltaSeconds) {
	Super::Tick(DeltaSeconds);
	
	if (playerActor != NULL && inTrigger) {
		if (DistanceToTriggerEdge(playerActor->GetActorLocation()) > distanceToTeleport && !movePlayer) {
			movePlayer = true;
			FVector playerLoc = playerActor->GetActorLocation();
			if (posYEntrance) { 
				playerLoc += moveVector; 
			}
			else {
				playerLoc -= moveVector;
			}
			playerActor->SetActorLocation(playerLoc);
		}
	}
}

//Check to see if the player has entered the teleport object
void ATriggerPortal::OnOverlapBegin(class AActor* OverlappedActor, class AActor* OtherActor) {
	if (OtherActor && (OtherActor != this)) {
		if (OtherActor->ActorHasTag(FName(TEXT("Player")))) {
			playerActor = OtherActor;
			inTrigger = true;
		}
	}
}

//Check to see if the player has left the teleport object
void ATriggerPortal::OnOverlapEnd(class AActor* OverlappedActor, class AActor* OtherActor) {
	if (OtherActor && OtherActor != this) {
		if (OtherActor->ActorHasTag(FName(TEXT("Player")))) {
			playerActor = NULL;
			movePlayer = false;
			inTrigger = false;
		}
	}
}

//Return the players distance to the edge of the trigger - dependant on the triggers entrance
float ATriggerPortal::DistanceToTriggerEdge(FVector playerLoc) {
	UBoxComponent* box = (UBoxComponent*)GetCollisionComponent();
	FVector triggerSize = box->GetScaledBoxExtent();
	FVector edgeLoc = GetActorLocation();
	if (posYEntrance) {
		edgeLoc.Y += triggerSize.Y;
	}
	else {
		edgeLoc.Y -= triggerSize.Y;
	}
	FVector vDist = playerLoc - edgeLoc;
	return FMath::Abs(vDist.Y);
}