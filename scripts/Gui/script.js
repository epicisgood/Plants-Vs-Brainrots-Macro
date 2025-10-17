function switchTab(tabId) {
  document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
  document.getElementById(tabId).classList.add('active');
}



let cachedData = null;

async function fetchAllItems() {
  if (!cachedData) {
    const response = await fetch('https://raw.githubusercontent.com/epicisgood/PVB-Updater/refs/heads/main/items.json');
    cachedData = await response.json();
  }
  return cachedData;
}

async function getItems(category) {
  const data = await fetchAllItems();
  return data[category].map(item => item.name);
}

async function getItemJSON(category) {
  const data = await fetchAllItems();
  return data[category];
}



async function onSaveClick() {
  const seedItems = await getItems("Seeds");
  const gearItems = await getItems("Gears");

  seedItems.push("Seeds");
  gearItems.push("Gears");

  const cfg = {
    url: document.getElementById('url').value,
    discordID: document.getElementById('discordID').value,
    VipLink: document.getElementById('VipLink').value,
    HitList: +document.getElementById('HitList').checked,
    EquipBest: +document.getElementById('EquipBest').checked,
    seedItems: {},
    gearItems: {},
  };

  const allLists = {
    seedItems,
    gearItems,
  };

  for (const [listName, items] of Object.entries(allLists)) {
    items.forEach(name => {
      const key = name.replace(/\s+/g, '');
      const element = document.getElementById(key);
      if (element) {
        cfg[listName][name] = element.checked;
      }
    });
}

  ahk.Save.Func(JSON.stringify(cfg));
  console.log(cfg);
}
  

  
function applySettings(a) {
    const s = a.data;
    console.log("Applying settings with these settings: ", s);

    document.getElementById('url').value       = s.url;
    document.getElementById('discordID').value = s.discordID;
    document.getElementById('HitList').checked  = !!+s.HitList
    document.getElementById('EquipBest').checked  = !!+s.EquipBest
    document.getElementById('VipLink').value   = s.VipLink;

    const allItems = {
      SeedItems: s.SeedItems,
      GearItems: s.GearItems,
    };

    for (const [listName, items] of Object.entries(allItems)) {
      for (const item in items) {
        const formattedItem = item.replace(/\s+/g, '');
        const element = document.getElementById(formattedItem);
        if (element) {
          element.checked = !!+items[item];
          console.log(element, items[item])
        }
      }
    }

}


async function AddHtml() {
  const categories = [
    "Seeds", "Gears",
    ];

  for (const category of categories) {
    const items = await getItemJSON(category);

    const rewardGrid = document.querySelector(`#${category}Grid`);
    if (!rewardGrid) continue;

    for (const item of items) {
      const sanitizedName = item.name.replace(/\s+/g, '');
      const imgPath = item.image || `../../images/${category}/${item.name}.webp`;

      const inputType = (category === "GearCrafting" || category === "SeedCrafting") ? "radio" : "checkbox";
      const inputName = (inputType === "radio") ? `name="${category}"` : "";

      const div = document.createElement("div");
      div.className = "reward-box";
      div.innerHTML = `
        <div class="reward-header">
          <img src="${imgPath}" style="width: 32.5px; height: 32.5px; margin-right: 3px; vertical-align: middle;" onerror="this.src='../../images/Other/Placeholder.webp'">
          <span>${item.name}</span>
        </div>
        <div class="reward-options">
          <label><input type="${inputType}" id="${sanitizedName}" ${inputName}>Claim</label>
        </div>
      `;

      rewardGrid.appendChild(div);
    }
  }
}



document.addEventListener("DOMContentLoaded", async () => {
    await AddHtml()
    ahk.ReadSettings.Func()
    window.chrome.webview.addEventListener('message', applySettings);
  })


document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".SelectAll").forEach(selectAllCheckbox => {
    selectAllCheckbox.addEventListener("change", () => {
      const rewardGrid = selectAllCheckbox.closest(".rewards-grid");
      if (!rewardGrid) return;

      const checkboxes = rewardGrid.querySelectorAll("input[type='checkbox']");

      checkboxes.forEach(cb => {
        const isSelectAll = cb.classList.contains("SelectAll");
        const isEnableCheckbox = [
          "Seeds", "Gears"
        ].includes(cb.id);
        if (!isSelectAll && !isEnableCheckbox) {
          cb.checked = selectAllCheckbox.checked;
        }
      });
    });
  });
});




















// Html cool stuff

document.querySelectorAll('.tabs button').forEach(button => {
  button.addEventListener('click', function() {
    document.querySelectorAll('.tabs button').forEach(btn => {
      btn.classList.remove('tab-button-active');
    });
    this.classList.add('tab-button-active');
  });
});

document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('.tabs button').classList.add('tab-button-active');
});


document.querySelectorAll('.custom-dropdown').forEach(dropdown => {
  const selected = dropdown.querySelector('.custom-dropdown-selected');
  const options = dropdown.querySelector('.custom-dropdown-options');
  const hiddenInput = document.getElementById('hiddenSelector');

  selected.addEventListener('click', () => {
    options.style.display = options.style.display === 'block' ? 'none' : 'block';
  });

  options.querySelectorAll('[data-value]').forEach(option => {
    option.addEventListener('click', () => {
      const value = option.getAttribute('data-value');
      selected.textContent = option.textContent;
      hiddenInput.value = value;
      options.style.display = 'none';
    });
  });

  document.addEventListener('click', e => {
    if (!dropdown.contains(e.target)) {
      options.style.display = 'none';
    }
  });
});


document.querySelectorAll('.custom-dropdown-options div[data-value]').forEach(option => {
  option.addEventListener('click', function () {
    const selected = this.closest('.custom-dropdown').querySelector('.custom-dropdown-selected');
    const selectedKey = selected.getAttribute('data-value');

    const hiddenInput = document.querySelector(`input[type="hidden"][data-value="${selectedKey}"]`);

    const value = this.getAttribute('data-value');
    const text = this.textContent.trim();

    if (hiddenInput) {
      hiddenInput.value = value;
    }

    const img = this.querySelector('img');
    if (img) {
      const newImg = img.cloneNode(true);
      selected.innerHTML = ''; 
      selected.appendChild(newImg);
      selected.append(' ' + text);
    } else {
      selected.textContent = text;
    }
  });
});






function selectDropdownValueByData(value) {
  const option = document.querySelector(`.custom-dropdown-options div[data-value="${value}"]`);
  if (!option) return;

  const dropdown = option.closest('.custom-dropdown');
  const selected = dropdown.querySelector('.custom-dropdown-selected');
  const hiddenInput = document.getElementById('hiddenSelector');
  const text = option.textContent.trim();

  hiddenInput.value = value;

  const img = option.querySelector('img');
  if (img) {
    const newImg = img.cloneNode(true);
    selected.innerHTML = '';
    selected.appendChild(newImg);
    selected.append(' ' + text);
  } else {
    selected.textContent = text;
  }

  dropdown.querySelector('.custom-dropdown-options').style.display = 'none';
}
