#pragma once

#include "CoreMinimal.h"
#include "Engine/TriggerBox.h"
#include "TriggerPortal.generated.h"

UCLASS()
class HORRORHOUSE_API ATriggerPortal : public ATriggerBox
{
	GENERATED_BODY()

protected:
	virtual void Tick(float DeltaSeconds) override;

public:
	ATriggerPortal();

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite, Category = "Trigger Portal")
		bool posYEntrance;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite, Category = "Trigger Portal")
		float distanceToTeleport;		

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Trigger Portal")
		bool inTrigger;

	UPROPERTY(VisibleAnywhere, BlueprintReadWrite, Category = "Trigger Portal")
		bool movePlayer;

	UFUNCTION()
		void OnOverlapBegin(class AActor* OverlappedActor, class AActor* OtherActor);

	UFUNCTION()
		void OnOverlapEnd(class AActor* OverlappedActor, class AActor* OtherActor);

private:
	//variables -----------------------------------------------------
	class AActor* playerActor;
	FVector moveVector;
	
	//functions -----------------------------------------------------
	float DistanceToTriggerEdge(FVector playerLoc);
	
};
