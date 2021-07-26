using UnityEngine;
using UnityEngine.UI;

public class Statistics : MonoBehaviour
{
    public float CurrentHealth { get; private set; }
    public float MaximumHealth { get; private set; }
    public float CurrentRadiation { get; private set; }
    public float RegenSpeed { get; private set; }

    public Slider HealthSlider;
    public Slider RadiationSlider;
    public Slider RegenHealthSlider;

    private float healthToRegen = 0f;

    void Start()
    {
        MaximumHealth = 100f;
        CurrentHealth = MaximumHealth;
        CurrentRadiation = 0f;
        HealthSlider.maxValue = MaximumHealth;
        RadiationSlider.maxValue = MaximumHealth;
        RegenHealthSlider.maxValue = MaximumHealth;
        SetRegenSpeed(5f);
        ChangeHealthUI();
        ChangeRadiationUI();
        ResetRegenHealthUI();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Keypad1)) AddRadiation(10F);
        if (Input.GetKeyDown(KeyCode.Keypad2)) GetDamage(10F);
        if (Input.GetKeyDown(KeyCode.Keypad3)) RemoveRadiation(10F);
        if (Input.GetKeyDown(KeyCode.Keypad4)) Heal(10F);
        if (Input.GetKeyDown(KeyCode.Keypad5)) AddHealthRegen(10F);

        if (healthToRegen > 0f)
        {
            if (healthToRegen < 0f)
            {
                healthToRegen = 0f;            
            }
            else
            {
                float regen = Time.deltaTime * RegenSpeed;
                healthToRegen -= regen;
                Heal(regen);
            }
        }
        else ResetRegenHealthUI();
    }

    void ChangeHealthUI()
    {
        HealthSlider.value = CurrentHealth;
    }

    void ChangeRadiationUI()
    {
        RadiationSlider.value = CurrentRadiation;
    }

    void ChangeRegenHealthUI()
    {
        RegenHealthSlider.value = CurrentHealth + healthToRegen;
    }

    void ResetRegenHealthUI()
    {
        RegenHealthSlider.value = 0;
    }

    public void Heal(float value)
    {
        if (value > 0)
        {           
            CurrentHealth += value;
            if (CurrentHealth > MaximumHealth - CurrentRadiation) CurrentHealth = MaximumHealth - CurrentRadiation;
            ChangeHealthUI();
        }
    }

    public void GetDamage(float value)
    {
        if (value > 0)
        {
            CurrentHealth -= value;        
            if (CurrentHealth <= 0)
            {
                CurrentHealth = 0;
                Death();
            }
            ChangeHealthUI();
        }
    }

    public void AddRadiation(float value)
    {
        if (value > 0)
        {
            CurrentRadiation += value;         
            if (CurrentHealth > MaximumHealth - CurrentRadiation) GetDamage(CurrentHealth - MaximumHealth + CurrentRadiation);
            ChangeRadiationUI();
        }
    }

    public void RemoveRadiation(float value)
    {
        if (value > 0)
        {
            CurrentRadiation -= value;
            if (CurrentRadiation < 0) CurrentRadiation = 0;
            ChangeRadiationUI();
        }
    }

    public void AddHealthRegen(float value)
    {
        if (value > 0)
        {
            healthToRegen += value;
            if (healthToRegen + CurrentHealth > MaximumHealth - CurrentRadiation) healthToRegen = MaximumHealth - CurrentRadiation - CurrentHealth;
            ChangeRegenHealthUI();
        }
    }

    public void SetRegenSpeed(float value)
    {
        if (value > 0) RegenSpeed = value;
    }

    void Death()
    {
        print("You died!");
    }
}
